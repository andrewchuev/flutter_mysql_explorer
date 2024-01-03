# Flutter MySQL Database Viewer

## Overview
This Flutter application is designed to connect to a local MySQL server and display the available databases and their tables. Users can view the list of databases, expand to see the tables within a database, and tap on a table to view its contents.

## Features
- View a list of databases from a MySQL server.
- Explore tables within each database.
- View table contents with both horizontal and vertical scrolling capabilities.

## Getting Started
To run this project, you will need Flutter installed on your machine. Follow the Flutter [installation guide](https://flutter.dev/docs/get-started/install) if you haven't set it up yet.

### Prerequisites
- A local MySQL server running at `192.168.88.56` (can be modified as per your setup).
- MySQL user credentials (default set to `homestead` with password `secret`).

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/andrewchuev/flutter_mysql_explorer
   ```
2. Navigate to the project directory and install dependencies:
   ```bash
   cd [project-directory]
   flutter pub get
   ```
3. Ensure your MySQL server is running and accessible.

4. Run the application:
   ```bash
   flutter run
   ```

## Usage
The application will connect to your MySQL server on launch. Here's how you can navigate through it:
- The home screen lists all the databases from the server.
- Tap on a database to view its tables.
- Tap on a table to view its contents in a scrollable table format.



