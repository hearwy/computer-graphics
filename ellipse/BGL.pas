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

procedure ClearDevice;
procedure Draw;

{==================================================================}

implementation

type
   float = real;

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
   LB[SizeX * y + x] := C;
end;



// { ============ Ellipse ============ }

procedure FillEllipse(x1, y1, x2, y2: integer);
var
   x, y, d: int64;
   tanx, tany, cx, cy: int64;
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
   
   tanx := round(a2 / sqrt(a2 + b2));
   tany := round(b2 / sqrt(a2 + b2));
   
   y := b;
   d := 2 * b2 - 2 * a2 * b + a2;
   for x := 0 to tanx do begin
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