@echo off
echo Executando testes com Robot Framework...
robot --output output.xml --log log.html --report report.html tests
echo.
echo Testes finalizados. Relatórios gerados:
echo - log.html
echo - report.html
pause
