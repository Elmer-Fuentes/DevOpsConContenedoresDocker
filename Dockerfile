# ==========================================
# ETAPA 1: Base de ejecución
# ==========================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

# ==========================================
# ETAPA 2: Restauración de dependencias
# ==========================================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiar el archivo desde la ubicación real
COPY ["DevOpsConContenedoresDocker.csproj", "./"]
RUN dotnet restore "DevOpsConContenedoresDocker.csproj"

# ==========================================
# ETAPA 3: Compilación
# ==========================================
COPY . .

# Eliminamos el Dockerfile dentro del contenedor antes de compilar
RUN rm -f Dockerfile
RUN dotnet build "DevOpsConContenedoresDocker.csproj" -c Release -o /app/build
# ==========================================
# ETAPA 4: Publicación
# ==========================================
FROM build AS publish
RUN dotnet publish "DevOpsConContenedoresDocker.csproj" -c Release -o /app/publish /p:UseAppHost=false

# ==========================================
# ETAPA 5: Imagen Final
# ==========================================
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:80
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

ENTRYPOINT ["dotnet", "DevOpsConContenedoresDocker.dll"]