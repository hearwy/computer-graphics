{$apptype console}
program BGLTest;

uses
   GraphABC, BGL;

const
   CountEllipse = 5000;

//Основное задание
procedure TestAllPatterns;
begin
   BGL.SetBackgroundColor(BGL.White);
   BGL.ClearDevice;

   // 1. Сплошная заливка 
   BGL.SetFillStyle(FillStyle.Solid);
   BGL.SetColor(BGL.Red);
   BGL.FillEllipse(30, 30, 280, 190);

   // 2. Вертикальная штриховка 
   BGL.SetFillStyle(FillStyle.Hatch);
   BGL.SetHatchStyle(HatchStyle.Vertical);
   BGL.SetColor(BGL.Blue);
   BGL.FillEllipse(320, 30, 570, 190);

   // 3. Горизонтальная штриховка 
   BGL.SetFillStyle(FillStyle.Hatch);
   BGL.SetHatchStyle(HatchStyle.Horizontal);
   BGL.SetColor(BGL.Green);
   BGL.FillEllipse(610, 30, 860, 190);

   // 4. Прямая диагональная штриховка 
   BGL.SetFillStyle(FillStyle.Hatch);
   BGL.SetHatchStyle(HatchStyle.ForwardDiagonal);
   BGL.SetColor(BGL.Magenta);
   BGL.FillEllipse(30, 230, 280, 390);

   // 5. Обратная диагональная штриховка
   BGL.SetFillStyle(FillStyle.Hatch);
   BGL.SetHatchStyle(HatchStyle.BackwardDiagonal);
   BGL.SetColor(BGL.Cyan);
   BGL.FillEllipse(320, 230, 570, 390);

   // 6. Точечная штриховка
   BGL.SetFillStyle(FillStyle.Hatch);
   BGL.SetHatchStyle(HatchStyle.Percent);
   BGL.SetColor(BGL.Black);
   BGL.FillEllipse(610, 230, 860, 390);

   // 7. Узкий вертикальный эллипс (a < b) с горизонтальной штриховкой
   BGL.SetFillStyle(FillStyle.Hatch);
   BGL.SetHatchStyle(HatchStyle.Horizontal);
   BGL.SetColor(BGL.Red);
   BGL.FillEllipse(40, 420, 120, 580);

   // 8. Узкий горизонтальный эллипс (a > b) с вертикальной штриховкой
   BGL.SetFillStyle(FillStyle.Hatch);
   BGL.SetHatchStyle(HatchStyle.Vertical);
   BGL.SetColor(BGL.Blue);
   BGL.FillEllipse(150, 460, 420, 540);

   // 9. Окружность (a = b) 
   BGL.SetFillStyle(FillStyle.Hatch);
   BGL.SetHatchStyle(HatchStyle.ForwardDiagonal);
   BGL.SetColor(BGL.Red);
   BGL.FillEllipse(460, 420, 620, 580);

   BGL.SetHatchStyle(HatchStyle.BackwardDiagonal);
   BGL.SetColor(BGL.Blue);
   BGL.FillEllipse(460, 420, 620, 580);

   BGL.Draw;
end;

//Концентрические эллипсы
procedure TestConcentric;
begin
   BGL.SetBackgroundColor(BGL.White);
   BGL.ClearDevice;

   //Сплошная заливка
   BGL.SetFillStyle(FillStyle.Solid);
   BGL.SetColor(BGL.Red);
   BGL.ConcentricEllipse(230, 110, 130, 65, 50, 28, 30);
   BGL.SetColor(BGL.Blue);
   BGL.ConcentricEllipseSlow(630, 110, 130, 65, 50, 28, 30);

   //Горизонтальная штриховка с поворотом 
   BGL.SetFillStyle(FillStyle.Hatch);
   BGL.SetHatchStyle(HatchStyle.Horizontal);
   BGL.SetColor(BGL.Blue);
   BGL.ConcentricEllipse(230, 300, 130, 65, 50, 28, 40);
   BGL.ConcentricEllipseSlow(630, 300, 130, 65, 50, 28, 40);

   //Диагональная штриховка с поворотом 
   BGL.SetFillStyle(FillStyle.Hatch);
   BGL.SetHatchStyle(HatchStyle.BackwardDiagonal);
   BGL.SetColor(BGL.Green);
   BGL.ConcentricEllipse(230, 490, 130, 65, 50, 28, -25);
   BGL.ConcentricEllipseSlow(630, 490, 130, 65, 50, 28, -25);

   BGL.Draw;
end;

//Функции для измерения времени BGL и GraphABC
function MeasureBGLSolid(n: integer): integer;
var
   i, t0: integer;
begin
   BGL.ClearDevice;
   BGL.SetFillStyle(FillStyle.Solid);
   BGL.SetColor(BGL.Red);
   t0 := Milliseconds;
   for i := 1 to n do
      BGL.FillEllipse(50 + (i mod 600), 40 + (i mod 380), 250 + (i mod 600), 180 + (i mod 380));
   BGL.Draw;
   Result := Milliseconds - t0;
end;

function MeasureBGLHatch(hStyle: BGL.HatchStyle; n: integer): integer;
var
   i, t0: integer;
begin
   BGL.ClearDevice;
   BGL.SetFillStyle(FillStyle.Hatch);
   BGL.SetHatchStyle(hStyle);
   BGL.SetColor(BGL.Blue);
   t0 := Milliseconds;
   for i := 1 to n do
      BGL.FillEllipse(50 + (i mod 600), 40 + (i mod 380), 250 + (i mod 600), 180 + (i mod 380));
   BGL.Draw;
   Result := Milliseconds - t0;
end;

function MeasureGraphABCSolid(n: integer): integer;
var
   i, t0: integer;
begin
   LockDrawing;
   GraphABC.ClearWindow(clWhite);
   SetBrushStyle(bsSolid);
   SetBrushColor(clRed);
   SetPenStyle(psClear);
   t0 := Milliseconds;
   for i := 1 to n do
      GraphABC.FillEllipse(50 + (i mod 600), 40 + (i mod 380), 250 + (i mod 600), 180 + (i mod 380));
   Redraw;
   Result := Milliseconds - t0;
   UnlockDrawing;
end;

function MeasureGraphABCHatch(gHatch: GraphABC.HatchStyle; n: integer): integer;
var
   i, t0: integer;
begin
   LockDrawing;
   GraphABC.ClearWindow(clWhite);
   SetBrushStyle(bsHatch);
   SetBrushHatch(gHatch);
   SetBrushColor(clBlue);
   SetPenStyle(psClear);
   t0 := Milliseconds;
   for i := 1 to n do
      GraphABC.FillEllipse(50 + (i mod 600), 40 + (i mod 380), 250 + (i mod 600), 180 + (i mod 380));
   Redraw;
   Result := Milliseconds - t0;
   UnlockDrawing;
end;

//Экспериментальное сравнение BGL.FillEllipse и GraphABC.FillEllipse
procedure RunPerformanceComparison;
var
   tBGL, tGABC: integer;
   counts: array[0..4] of integer = (500, 1000, 2500, 5000, 10000);
   idx, n: integer;
begin
   writeln('===========================================================================');
   writeln(' Сравнение процедур FillEllipse');
   writeln(' Размер окна: ', BGL.SizeX, 'x', BGL.SizeY, ', размер эллипса: 200x140 пикс.');
   writeln('===========================================================================');
   writeln;
   writeln('Таблица 1. Сравнение по всем стилям узора закраски (N = ', CountEllipse, ' эллипсов):');
   writeln('---------------------------------------------------------------------------');
   writeln(' Стиль / Узор закраски        | BGL (мс) | GraphABC (мс) | Ускорение (раз)');
   writeln('---------------------------------------------------------------------------');

   // 1. Сплошная заливка 
   tBGL  := MeasureBGLSolid(CountEllipse);
   tGABC := MeasureGraphABCSolid(CountEllipse);
   writeln(Format(' 1. Solid                     | {0,8} | {1,13} | {2,14:F2}x',
      tBGL, tGABC, tGABC / Max(tBGL, 1)));

   // 2. Вертикальная штриховка
   tBGL  := MeasureBGLHatch(HatchStyle.Vertical, CountEllipse);
   tGABC := MeasureGraphABCHatch(bhVertical, CountEllipse);
   writeln(Format(' 2. Hatch: Vertical           | {0,8} | {1,13} | {2,14:F2}x',
      tBGL, tGABC, tGABC / Max(tBGL, 1)));

   // 3. Горизонтальная штриховка 
   tBGL  := MeasureBGLHatch(HatchStyle.Horizontal, CountEllipse);
   tGABC := MeasureGraphABCHatch(bhHorizontal, CountEllipse);
   writeln(Format(' 3. Hatch: Horizontal         | {0,8} | {1,13} | {2,14:F2}x',
      tBGL, tGABC, tGABC / Max(tBGL, 1)));

   // 4. Прямая диагональная штриховка
   tBGL  := MeasureBGLHatch(HatchStyle.ForwardDiagonal, CountEllipse);
   tGABC := MeasureGraphABCHatch(bhForwardDiagonal, CountEllipse);
   writeln(Format(' 4. Hatch: ForwardDiagonal    | {0,8} | {1,13} | {2,14:F2}x',
      tBGL, tGABC, tGABC / Max(tBGL, 1)));

   // 5. Обратная диагональная штриховка
   tBGL  := MeasureBGLHatch(HatchStyle.BackwardDiagonal, CountEllipse);
   tGABC := MeasureGraphABCHatch(bhBackwardDiagonal, CountEllipse);
   writeln(Format(' 5. Hatch: BackwardDiagonal   | {0,8} | {1,13} | {2,14:F2}x',
      tBGL, tGABC, tGABC / Max(tBGL, 1)));

   // 6. Точечная штриховка
   tBGL  := MeasureBGLHatch(HatchStyle.Percent, CountEllipse);
   tGABC := MeasureGraphABCHatch(bhPercent75, CountEllipse);
   writeln(Format(' 6. Hatch: Percent            | {0,8} | {1,13} | {2,14:F2}x',
      tBGL, tGABC, tGABC / Max(tBGL, 1)));
   writeln('---------------------------------------------------------------------------');
   writeln;

   writeln('Таблица 2. Зависимость времени выполнения от числа эллипсов N:');
   writeln('---------------------------------------------------------------------------');
   writeln(' Число эллипсов N             | BGL (мс) | GraphABC (мс) | Ускорение (раз)');
   writeln('---------------------------------------------------------------------------');
   for idx := 0 to 4 do
   begin
      n := counts[idx];
      tBGL  := MeasureBGLHatch(HatchStyle.ForwardDiagonal, n);
      tGABC := MeasureGraphABCHatch(bhForwardDiagonal, n);
      writeln(Format(' N = {0,6}                   | {1,8} | {2,13} | {3,14:F2}x',
         n, tBGL, tGABC, tGABC / Max(tBGL, 1)));
   end;
   writeln('---------------------------------------------------------------------------');
   writeln('Конец');
end;

begin
  
   RunPerformanceComparison;
   TestAllPatterns;
   Sleep(5000);
   TestConcentric;
   
end.
