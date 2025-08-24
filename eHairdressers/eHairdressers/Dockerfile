#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 7051
#//EXPOSE 80
#//EXPOSE 443
ENV ASPNETCORE_URLS=HTTP://+:7051

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["eHairdressers/eHairdressers.csproj", "eHairdressers/"]
COPY ["eHairdressers.Services/eHairdressers.Services.csproj", "eHairdressers.Services/"]
COPY ["eHairdressers.Model/eHairdressers.Model.csproj", "eHairdressers.Model/"]
RUN dotnet restore "eHairdressers/eHairdressers.csproj"
COPY . .
WORKDIR "/src/eHairdressers"
RUN dotnet build "eHairdressers.csproj" -c Release -o /app/build

FROM build AS publish
WORKDIR "/src/eHairdressers"
RUN dotnet publish "eHairdressers.csproj" -c Release -o /app
#/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
#/publish
# Copy wwwroot folder from root context
COPY wwwroot ./wwwroot
ENTRYPOINT ["dotnet", "eHairdressers.dll"]