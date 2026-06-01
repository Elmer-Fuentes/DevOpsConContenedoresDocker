FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copia solo el proyecto
COPY ["DevOpsConContenedoresDocker.csproj", "./"]
RUN dotnet restore "DevOpsConContenedoresDocker.csproj"

# ESTO ES LO QUE NECESITAS:
RUN rm -f Dockerfile && dotnet build "DevOpsConContenedoresDocker.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "DevOpsConContenedoresDocker.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DevOpsConContenedoresDocker.dll"]