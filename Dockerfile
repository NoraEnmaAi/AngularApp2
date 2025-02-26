# Base Image for Running the Application
FROM mcr.microsoft.com/dotnet/aspnet:8.0-nanoserver-1809 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Build Stage with Node.js & .NET SDK
FROM mcr.microsoft.com/dotnet/sdk:8.0-nanoserver-1809 AS build-env
WORKDIR /src

User ContainerAdministrator

# Install Node.js (Fix: Use a Proper Installation Method)
RUN powershell -Command \
    Invoke-WebRequest -Uri "https://nodejs.org/dist/v18.18.0/node-v18.18.0-win-x64.zip" -OutFile "node.zip"; \
    Expand-Archive -Path node.zip -DestinationPath C:\nodejs; \
    setx PATH "%PATH%;C:\nodejs"

# Install Angular CLI
RUN npm install -g @angular/cli

# Copy .NET Server and Client Projects (Fix: Use Correct Paths)
COPY AngularApp2.Server/AngularApp2.Server.csproj AngularApp2.Server/
COPY angularapp2.client/angularapp2.client.esproj angularapp2.client/
RUN dotnet restore AngularApp2.Server/AngularApp2.Server.csproj

# Copy Everything
COPY . .

# Build Backend
WORKDIR /src/AngularApp2.Server
RUN dotnet build -c Release -o /app/build

# Build Frontend
WORKDIR /src/angularapp2.client
RUN npm install
RUN ng build --configuration production

# Publish Backend
FROM build-env AS publish
WORKDIR /src/AngularApp2.Server
RUN dotnet publish -c Release -o /app/publish /p:UseAppHost=false

# Final Stage: Run the Application
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Copy Built Angular Files to wwwroot
COPY --from=publish /src/angularapp2.client/dist/angularapp2.client /app/wwwroot

ENTRYPOINT ["dotnet", "AngularApp2.Server.dll"]
