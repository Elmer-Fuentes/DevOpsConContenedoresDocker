# ==========================================
# ETAPA 1: Base de ejecución (Runtime ultra ligero)
# ==========================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
# Exponer los puertos estándar internamente
EXPOSE 80
EXPOSE 443

# ==========================================
# ETAPA 2: Restauración de dependencias (Caché de NuGet)
# ==========================================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiar UNICAMENTE el archivo .csproj desde la subcarpeta
COPY ["DevOpsConContenedoresDocker.csproj", "./"]
RUN dotnet restore "DevOpsConContenedoresDocker.csproj" --verbosity detailed
# ==========================================
# ETAPA 3: Compilación del código fuente
# ==========================================
COPY . .
WORKDIR "/src/DevOpsConContenedoresDocker"
RUN dotnet build "DevOpsConContenedoresDocker.csproj" -c Release -o /app/build

# ==========================================
# ETAPA 4: Publicación y optimización de binarios
# ==========================================
FROM build AS publish
RUN dotnet publish "DevOpsConContenedoresDocker.csproj" -c Release -o /app/publish /p:UseAppHost=false --verbosity detailed

# ==========================================
# ETAPA 5: Imagen Final limpia (Producción)
# ==========================================
FROM base AS final
WORKDIR /app

# Copiar solo el resultado limpio de la publicación
COPY --from=publish /app/publish .

# Variables de entorno profesionales para producción
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:80
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

ENTRYPOINT ["dotnet", "DevOpsConContenedoresDocker.dll"]