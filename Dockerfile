# Imagen base para build y ejecución
FROM mcr.microsoft.com/dotnet/sdk:8.0
WORKDIR /app

# Copiar todo el código fuente
COPY . .

# Ejecutar la aplicación directamente
CMD ["dotnet", "run", "--project", "src/Web/Web.csproj"]