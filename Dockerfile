# ========================================================================================
# Dockerfile corregido - ASP.NET Core MVC (.NET 8)
# Proyecto: DevOpsConContenedoresDocker
#
# Construir imagen:
#   docker build -t devopscontenedoresdocker:v1 .
#
# Ejecutar contenedor:
#   docker run -d --name devops-web -p 8080:8080 devopscontenedoresdocker:v1
# ========================================================================================

# Etapa 1: Runtime liviano para ejecutar la aplicación publicada
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app

# Usamos 8080 porque es el puerto recomendado por defecto en imágenes .NET 8.
EXPOSE 8080

# Forzamos a ASP.NET Core a escuchar dentro del contenedor en el puerto 8080.
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Etapa 2: SDK para restaurar dependencias y compilar
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiar primero el .csproj permite aprovechar caché de Docker en restore.
COPY ["DevOpsConContenedoresDocker.csproj", "./"]
RUN dotnet restore "DevOpsConContenedoresDocker.csproj"

# IMPORTANTE:
# Se copia todo el código fuente antes de compilar y publicar.
# En tu Dockerfile anterior faltaba esta línea antes del build.
COPY . .

RUN dotnet build "DevOpsConContenedoresDocker.csproj" -c Release -o /app/build

# Etapa 3: Publicación optimizada
FROM build AS publish
RUN dotnet publish "DevOpsConContenedoresDocker.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Etapa 4: Imagen final
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "DevOpsConContenedoresDocker.dll"]
