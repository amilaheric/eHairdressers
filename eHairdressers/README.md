# eHairdressers - Hair Salon Management System

A comprehensive hair salon management system built with .NET 7, featuring user management, appointment scheduling, product catalog, and RabbitMQ messaging.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- .NET 7 SDK (for development)

### 1. Clone the Repository
```bash
git clone <your-repository-url>
cd eHairdressers
```

### 2. Start the Application
```bash
docker-compose up -d
```

This will start:
- **SQL Server** on port 1433
- **RabbitMQ** on ports 5672 (AMQP) and 15672 (Management)
- **eHairdressers API** on port 7052

### 3. Access the Application
- **Swagger UI**: http://localhost:7052/swagger
- **API Base**: http://localhost:7052/api/

## 📊 Pre-seeded Data

The application comes with comprehensive sample data automatically seeded on first run:

### 👥 Users (16 total)
- **Real Users**: amila, emina, ermina, esma, arza
- **Sample Users**: John, Jane, Mike, Sarah, David, Emily, Chris, Anna, Tom, Lisa, Mark

### 🛍️ Products (9 total)
- **Real Products**:
  - serum (serum za vrhove) - 100.0 BAM
  - sampon (sampon za suhu kosu) - 80.0 BAM
  - Ulje za kosu (ulje za suhu kosu) - 100.0 BAM
  - regenerator - 50.0 BAM
  - kupka - 85.0 BAM
- **Additional Products**: Professional Shampoo, Conditioner, Hair Gel, Hair Spray

### ✂️ Services
- **sisanje** - Professional hair cutting service

### 🏷️ Categories & Brands
- **Category**: kerastase
- **Brand**: kerastase

### 📅 Sample Data
- **Appointments**: 3 sample appointments
- **Orders**: 2 sample orders with order items
- **Roles**: Customer, Employee, Admin

## 🔧 Development

### Running Locally
```bash
cd eHairdressers
dotnet run
```

### Database Migrations
The application automatically runs migrations and seeds data on startup.

### Testing the API
Use Swagger UI at http://localhost:7052/swagger to test all endpoints.

## 📡 API Endpoints

### Authentication
- **Basic Authentication** required for most endpoints
- **Username**: Any seeded user (e.g., "amila")
- **Password**: "hashed_password" (for testing)

### Key Endpoints
- `GET /api/User` - Get all users
- `GET /api/Products` - Get all products
- `GET /api/Services` - Get all services
- `GET /api/Appointment` - Get all appointments
- `GET /api/Orders` - Get all orders
- `GET /api/Messaging/status` - Check RabbitMQ connection

## 🐰 RabbitMQ Messaging

The system automatically sends messages when:
- **Orders are created** → `OrderCreatedMessage`
- **Appointments are created** → `AppointmentCreatedMessage`

### RabbitMQ Management
- **URL**: http://localhost:15672
- **Username**: admin
- **Password**: admin123

## 🗄️ Database

- **SQL Server 2022** running in Docker
- **Database**: eHairdressers
- **Connection**: Automatically configured for Docker environment

## 🔒 Security Features

- Basic Authentication
- Role-based access control
- CORS enabled for development

## 📁 Project Structure

```
eHairdressers/
├── Controllers/          # API Controllers
├── Services/            # Business Logic
├── Model/              # Data Models
├── Database/           # Database Context & Seed Data
└── Program.cs          # Application Configuration
```

## 🚨 Troubleshooting

### Common Issues

1. **Port 7052 already in use**
   ```bash
   docker-compose down
   docker-compose up -d
   ```

2. **Database connection issues**
   - Ensure SQL Server container is running
   - Check connection string in appsettings.json

3. **RabbitMQ connection issues**
   - Verify RabbitMQ container is running
   - Check ports 5672 and 15672

### Logs
```bash
# View application logs
docker-compose logs app

# View database logs
docker-compose logs sqlserver

# View RabbitMQ logs
docker-compose logs rabbitmq
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License.

## 🆘 Support

For support, please open an issue in the repository or contact the development team.

---

**Note**: This application is pre-configured with sample data to provide a complete testing environment. All data is automatically seeded on first run.
