FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["eHairdressers.Worker/eHairdressers.Worker.csproj", "eHairdressers.Worker/"]
COPY ["eHairdressers.Model/eHairdressers.Model.csproj", "eHairdressers.Model/"]
RUN dotnet restore "eHairdressers.Worker/eHairdressers.Worker.csproj"
COPY . .
WORKDIR "/src/eHairdressers.Worker"
RUN dotnet build "eHairdressers.Worker.csproj" -c Release -o /app/build

FROM build AS publish
WORKDIR "/src/eHairdressers.Worker"
RUN dotnet publish "eHairdressers.Worker.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "eHairdressers.Worker.dll"]
