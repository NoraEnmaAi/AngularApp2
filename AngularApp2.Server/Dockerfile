FROM mcr.microsoft.com/dotnet/aspnet:8.0-nanoserver-1809 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Build stage with Node.js for Angular
FROM mcr.microsoft.com/dotnet/sdk:8.0-nanoserver-1809 AS with-node
WORKDIR /src

# Download and extract Node.js
RUN curl -o node.zip https://nodejs.org/dist/v18.18.0/node-v18.18.0-win-x64.zip
RUN powershell -Command "Expand-Archive -Path node.zip -DestinationPath C:\\src\\node"

# Set the PATH for Node.js
RUN setx /M PATH "%PATH%;C:\\src\\node\\node-v18.18.0-win-x64"

# Install Angular CLI
RUN npm install -g @angular/cli

FROM with-node AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy and restore backend
COPY ["AngularApp2.Server.csproj", "."]
RUN dotnet restore "AngularApp2.Server.csproj"

# Copy all backend files
COPY . .

# Build backend
WORKDIR "/src/AngularApp2.Server"
RUN dotnet build "AngularApp2.Server.csproj" -c %BUILD_CONFIGURATION% -o /app/build

# Publish backend
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "AngularApp2.Server.csproj" -c %BUILD_CONFIGURATION% -o /app/publish /p:UseAppHost=false

# Final runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "AngularApp2.Server.dll"]
