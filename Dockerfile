# Imagen base para build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Instalar Node.js 20.x (en lugar de 18.x)
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Copiar archivos de solución y proyecto
COPY ["pipeline.sln", "Directory.Build.props", "Directory.Packages.props", "global.json", "./"]
COPY ["src/Application/Application.csproj", "src/Application/"]
COPY ["src/Domain/Domain.csproj", "src/Domain/"]
COPY ["src/Infrastructure/Infrastructure.csproj", "src/Infrastructure/"]
COPY ["src/Web/Web.csproj", "src/Web/"]

# Restaurar dependencias
RUN dotnet restore "pipeline.sln"

# Copiar el resto del código fuente
COPY ["src/", "src/"]

# Compilar y publicar la aplicación
RUN dotnet build "pipeline.sln" -c Release --no-restore
RUN dotnet publish "src/Web/Web.csproj" -c Release -o /app/publish --no-restore

# Imagen final
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet", "Web.dll"]