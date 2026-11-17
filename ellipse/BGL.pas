unit BGL;

interface

uses Display;

const
   Black   = $000000;
   White   = $FFFFFF;
   Red     = $FF0000;
   Green   = $00FF00;
   Blue    = $0000FF;
   Yellow  = $FFFF00;
   Magenta = $FF00FF;
   Cyan    = $00FFFF;
   
   HatchWidth = 3;
   HatchOffset = 7;
   
   SizeX = Display.SizeX;
   SizeY = Display.SizeY;
   GetMaxX = Display.GetMaxX;
   GetMaxY = Display.GetMaxY;

type
   FillStyle = (Solid, Hatch);
   HatchStyle = (Vertical, Horizontal, ForwardDiagonal, BackwardDiagonal, Percent);

procedure SetColor(C: tPixel);
procedure SetBackgroundColor(C: tPixel);

procedure SetFillStyle(s: FillStyle);
procedure SetHatchStyle(s: HatchStyle);

procedure PutPixel(x, y: integer; C: tPixel);

procedure FillEllipse(x1, y1, x2, y2: integer);
procedure ConcentricEllipse(cx, cy, bg_ax, bg_ay, sm_ax, sm_ay: integer; angle: real);
procedure ConcentricEllipseSlow(cx, cy, bg_ax, bg_ay, sm_ax, sm_ay: integer; angle: real);

procedure ClearDevice;
procedure Draw;

{==================================================================}

implementation

type
   TEllipse = record
      axis_x, axis_y: real;
      axis2_x, axis2_y: real;
      angle: real;
      cos2, sin2: real;
      a, b, c: real;
      max_y: real;
      y: integer;
      rx1, rx2: real;
   end;

var
   CC, BC: tPixel;
   CurrentFillStyle: FillStyle;
   CurrentHatchStyle: HatchStyle;

// { ============ Style ============ }

procedure SetColor(C: tPixel);
begin
   CC := C
end;

procedure SetBackgroundColor(C: tPixel);
begin
   BC := C;
end;

procedure SetFillStyle(s: FillStyle);
begin
   CurrentFillStyle := s;
end;

procedure SetHatchStyle(s: HatchStyle);
begin
   CurrentHatchStyle := s;
end;



// { ============ Utility ============ }

procedure PutPixel(x, y: integer; C: tPixel);
begin
   if (x >= 0) and (x < SizeX) and (y >= 0) and (y < SizeY) then
      LB[SizeX * y + x] := C;
end;

function PositiveMod(a, m: integer): integer;
var
   r: integer;
begin
   r := a mod m;
   if r < 0 then
      r := r + m;
   Result := r;
end;



// { ============ Ellipse ============ }

procedure FillEllipse(x1, y1, x2, y2: integer);
var
   x, y, d: int64;
   tx, ty, cx, cy: int64;
   a, b, a2, b2: int64;
   
   // { ============ Ellipse style ============ }
   
   procedure FillBufferVertical(y, x1, x2: integer);
   var
      x, rowOffset: integer;
   begin
      rowOffset := SizeX * y;
      for x := x1 to x2 do
         if x mod HatchOffset < HatchWidth then
            LB[rowOffset + x] := CC;
   end;
   
   procedure FillBufferHorizontal(y, x1, x2: integer);
   begin
      if y mod HatchOffset < HatchWidth then
         Fill(SizeX * y + x1, x2 - x1, CC);
   end;
   
   procedure FillBufferForwardDiagonal(y, x1, x2: integer);
   var
      x, rowOffset, baseDiag: integer;
   begin
      rowOffset := SizeX * y;
      baseDiag := SizeY - y;
      for x := x1 to x2 do
         if (x + baseDiag) mod HatchOffset < HatchWidth then
            LB[rowOffset + x] := CC;
   end;
   
   procedure FillBufferBackwardDiagonal(y, x1, x2: integer);
   var
      x, rowOffset: integer;
   begin
      rowOffset := SizeX * y;
      for x := x1 to x2 do
         if (x + y) mod HatchOffset < HatchWidth then
            LB[rowOffset + x] := CC;
   end;
   
   procedure FillBufferPercent(y, x1, x2: integer);
   var
      x, rowOffset: integer;
   begin
      if (y and 1) <> 0 then
         Fill(SizeX * y + x1, x2 - x1, CC)
      else begin
         rowOffset := SizeX * y;
         for x := x1 to x2 do
            if (x and 1) <> 0 then
               LB[rowOffset + x] := CC;
      end;
   end;
   
   procedure FillBuffer(y, x1, x2: integer);
   begin
      if CurrentFillStyle = FillStyle.Solid then
         Fill(SizeX * y + x1, x2 - x1, CC)
      else begin
         case CurrentHatchStyle of
            Vertical: 
               FillBufferVertical(y, x1, x2);
            Horizontal:
               FillBufferHorizontal(y, x1, x2);
            ForwardDiagonal:
               FillBufferForwardDiagonal(y, x1, x2);
            BackwardDiagonal:
               FillBufferBackwardDiagonal(y, x1, x2);
            Percent:
               FillBufferPercent(y, x1, x2);
         end;
      end;
   end;
   
// { ============ Ellipse impl ============ }

begin
   a := (x2 - x1) div 2 - 1;
   b := (y2 - y1) div 2 - 1;
   
   cx := (x1 + x2) div 2;
   cy := (y1 + y2) div 2;
   
   a2 := sqr(a);
   b2 := sqr(b);
   
   tx := round(a2 / sqrt(a2 + b2));
   ty := round(b2 / sqrt(a2 + b2));
   
   y := b;
   d := 2 * b2 - 2 * a2 * b + a2;
   for x := 0 to tx do begin
      if d < 0 then begin
         d := d + b2 * (2 * x + 5);
         end
      else begin
         FillBuffer(cy - y, cx - x, cx + x);
         FillBuffer(cy + y, cx - x, cx + x);
         
         d := d + b2 * (2 * x + 5) - a2 * (2 * y - 2);
         y := y - 1;
      end;
   end;
   
   for y := y downto 0 do begin
      FillBuffer(cy - y, cx - x, cx + x);
      FillBuffer(cy + y, cx - x, cx + x);
      
      if d < 0 then begin
         d := d + a2 * (2 * y - 5);
         end
      else begin
         d := d + a2 * (2 * y - 5) - b2 * (2 * x + 2);
         x := x + 1;
      end;
   end;
end;


// { ============ Concentric Rotated Ellipse ============ }

procedure InitEllipse(var e: TEllipse; ax, ay, ang: real);
begin
   //Полуоси и их квадраты
   e.axis_x := ax;
   e.axis_y := ay;
   e.axis2_x := sqr(ax);
   e.axis2_y := sqr(ay);
   
   e.angle := ang;
   e.cos2 := sqr(cos(ang));
   e.sin2 := sqr(sin(ang));
   
   //Коэффициенты квадратного уравнения повернутого эллипса
   e.a := e.axis2_x * e.sin2 + e.axis2_y * e.cos2;         
   e.b := sin(ang * 2) * (e.axis2_x - e.axis2_y);       
   e.c := e.axis2_x * e.cos2 + e.axis2_y * e.sin2;        
   
   e.max_y := sqrt(e.axis2_x * e.sin2 + e.axis2_y * e.cos2);
   
   //Начальная целая строка для перебора сверху вниз
   e.y := trunc(e.max_y);
   
   e.rx1 := 0;
   e.rx2 := 0;
end;

//Вычисление левой и правой границы для повернутого эллипса
procedure NextRowEllipse(var e: TEllipse);
var
   disc, d: real;
begin
   disc := sqr(e.y * e.b) - 4 * e.a * (sqr(e.y) * e.c - e.axis2_x * e.axis2_y);
   
   if disc < 0 then
      disc := 0;
   
   d := sqrt(disc);
   e.rx1 := (-(e.y * e.b) - d) / (2 * e.a);
   e.rx2 := (-(e.y * e.b) + d) / (2 * e.a);
end;

//Закрашивать пиксель или нет
function CheckHatch(x, y, cx, cy: integer; cosA, sinA: real): boolean;
var
   dx, dy: integer;
   u, v: real;
begin
   if CurrentFillStyle = FillStyle.Solid then begin
      Result := true;
      exit;
   end;

   dx := x - cx;
   dy := y - cy;
   
   //Поворот в локальные оси
   u := dx * cosA - dy * sinA;
   v := dx * sinA + dy * cosA;

   case CurrentHatchStyle of
      Vertical:
         Result := PositiveMod(round(u), HatchOffset) < HatchWidth;
      Horizontal:
         Result := PositiveMod(round(v), HatchOffset) < HatchWidth;
      ForwardDiagonal:
         Result := PositiveMod(round(u - v), HatchOffset) < HatchWidth;
      BackwardDiagonal:
         Result := PositiveMod(round(u + v), HatchOffset) < HatchWidth;
      Percent:
         Result := ((round(u) and 1) <> 0) or ((round(v) and 1) <> 0);
   end;
end;

//Отрисовка линий
procedure DrawRow(y, x1, x2, cx, cy: integer; cosA, sinA: real);
var
   mn, mx, x, rowOffset: integer;
begin
   if (y < 0) or (y >= SizeY) then
      exit;

   mn := x1;
   mx := x2;
   
   if mn > mx then
      exit;

   if mn < 0 then
      mn := 0;
   if mx >= SizeX then
      mx := SizeX - 1;
   if mn > mx then
      exit;

   if CurrentFillStyle = FillStyle.Solid then
      Fill(SizeX * y + mn, mx - mn + 1, CC)
   else begin
      rowOffset := SizeX * y;
      for x := mn to mx do
         if CheckHatch(x, y, cx, cy, cosA, sinA) then
            LB[rowOffset + x] := CC;
   end;
end;

procedure ConcentricEllipse(cx, cy, bg_ax, bg_ay, sm_ax, sm_ay: integer; angle: real);
var
   big, small: TEllipse;
   rad, cosA, sinA: real;
   sm_max_y: integer;
begin
   rad := angle * Pi / 180.0;
   cosA := cos(rad);
   sinA := sin(rad);

   InitEllipse(big, bg_ax, bg_ay, rad);
   InitEllipse(small, sm_ax, sm_ay, rad);
   sm_max_y := trunc(small.max_y);

   while big.y > sm_max_y do begin
      NextRowEllipse(big);
      DrawRow(cy - big.y, cx + ceil(-big.rx2), cx + floor(-big.rx1), cx, cy, cosA, sinA);
      DrawRow(cy + big.y, cx + ceil(big.rx1), cx + floor(big.rx2), cx, cy, cosA, sinA);
      big.y := big.y - 1;
   end;

   while big.y >= 0 do begin
      NextRowEllipse(big);
      NextRowEllipse(small);
      DrawRow(cy - big.y, cx + ceil(-big.rx2), cx + floor(-small.rx2), cx, cy, cosA, sinA);
      DrawRow(cy - big.y, cx + ceil(-small.rx1), cx + floor(-big.rx1), cx, cy, cosA, sinA);
      DrawRow(cy + big.y, cx + ceil(big.rx1), cx + floor(small.rx1), cx, cy, cosA, sinA);
      DrawRow(cy + big.y, cx + ceil(small.rx2), cx + floor(big.rx2), cx, cy, cosA, sinA);
      big.y := big.y - 1;
      small.y := small.y - 1;
   end;
end;

procedure ConcentricEllipseSlow(cx, cy, bg_ax, bg_ay, sm_ax, sm_ay: integer; angle: real);
var
   rad, sinA, cosA, sin2, cos2: real;
   axis_bg2_x, axis_bg2_y: real;
   axis_sm2_x, axis_sm2_y: real;
   _x, _y, bg_value, sm_value: real;
   max_x, max_y, x, y, px, py: integer;
begin
   rad := angle * Pi / 180.0;
   sinA := sin(rad);
   cosA := cos(rad);

   sin2 := sqr(sinA);
   cos2 := sqr(cosA);

   axis_bg2_x := sqr(bg_ax);
   axis_bg2_y := sqr(bg_ay);

   axis_sm2_x := sqr(sm_ax);
   axis_sm2_y := sqr(sm_ay);

   max_x := trunc(sqrt(axis_bg2_x * cos2 + axis_bg2_y * sin2));
   max_y := trunc(sqrt(axis_bg2_x * sin2 + axis_bg2_y * cos2));

   for y := -max_y to max_y do begin
      for x := -max_x to max_x do begin
         _x := x * cosA - y * sinA;
         _y := x * sinA + y * cosA;

         bg_value := sqr(_x) / axis_bg2_x + sqr(_y) / axis_bg2_y;
         sm_value := sqr(_x) / axis_sm2_x + sqr(_y) / axis_sm2_y;

         if (bg_value <= 1) and (sm_value >= 1) then begin
            px := cx + x;
            py := cy + y;
            if CheckHatch(px, py, cx, cy, cosA, sinA) then
               PutPixel(px, py, CC);
         end;
      end;
   end;
end;

// { ============ System ============ }

procedure ClearDevice;
begin
   Fill(0, SizeX * SizeY, BC);
end;

procedure Draw;
begin
   Display.Draw
end;

begin
   SetFillStyle(FillStyle.Solid);
   SetHatchStyle(HatchStyle.ForwardDiagonal);
  
   SetColor(Black);
   SetBackgroundColor(White);
   ClearDevice;
end.
