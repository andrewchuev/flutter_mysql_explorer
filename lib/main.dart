import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter MySQL App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DatabasesScreen(),
    );
  }
}

class DatabasesScreen extends StatelessWidget {
  const DatabasesScreen({super.key});

  Future<List<String>> getDatabases() async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
        host: '192.168.88.56',
        port: 3306,
        user: 'homestead',
        password: 'secret'));

    var results = await conn.query('SHOW DATABASES');
    List<String> databases = [];
    for (var row in results) {
      databases.add(row[0]);
    }

    await conn.close();
    return databases;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Список баз данных'),
      ),
      body: FutureBuilder<List<String>>(
        future: getDatabases(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Ошибка: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final databases = snapshot.data!;
            return ListView.builder(
              itemCount: databases.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(databases[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TablesScreen(database: databases[index])),
                    );
                  },
                );
              },
            );
          } else {
            return Text('Нет доступных баз данных');
          }
        },
      ),
    );
  }
}

class TablesScreen extends StatelessWidget {
  final String database;

  TablesScreen({required this.database});

  Future<List<String>> getTables(String dbName) async {

    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: '192.168.88.56',
      port: 3306,
      user: 'homestead',
      password: 'secret',
      db: dbName,
    ));


    var results = await conn.query('SHOW TABLES');


    List<String> tables = [];
    for (var row in results) {
      tables.add(row[0]);
    }


    await conn.close();
    return tables;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Таблицы базы данных: $database'),
      ),
      body: FutureBuilder<List<String>>(
        future: getTables(database),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Ошибка: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final tables = snapshot.data!;
            return ListView.builder(
              itemCount: tables.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tables[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TableContentScreen(database: database, table: tables[index])),
                    );
                  },
                );
              },
            );
          } else {
            return Text('Нет доступных таблиц в базе данных $database');
          }
        },
      ),
    );
  }
}




class TableContentScreen extends StatelessWidget {
  final String database;
  final String table;

  TableContentScreen({required this.database, required this.table});

  Future<List<DataColumn>> getColumnData(String dbName, String tableName) async {
    final conn = await createMySqlConnection();
    var results = await conn.query('DESCRIBE $tableName');

    List<DataColumn> columns = [];
    for (var row in results) {
      columns.add(DataColumn(label: Text(row[0])));
    }

    await conn.close();
    return columns;
  }

  Future<List<DataRow>> getRowData(String dbName, String tableName) async {
    final conn = await createMySqlConnection();
    var results = await conn.query('SELECT * FROM $tableName');

    List<DataRow> rows = [];
    for (var row in results) {
      List<DataCell> cells = row.fields.values.map((value) => DataCell(Text(value.toString()))).toList();
      rows.add(DataRow(cells: cells));
    }

    await conn.close();
    return rows;
  }

  Future<MySqlConnection> createMySqlConnection() async {
    return MySqlConnection.connect(ConnectionSettings(
      host: '192.168.88.56',
      port: 3306,
      user: 'homestead',
      password: 'secret',
      db: this.database,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Содержимое таблицы $table'),
      ),
      body: FutureBuilder<List<DataColumn>>(
        future: getColumnData(database, table),
        builder: (context, snapshotColumns) {
          if (snapshotColumns.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshotColumns.hasError) {
            return Text('Ошибка: ${snapshotColumns.error}');
          } else if (snapshotColumns.hasData) {
            return FutureBuilder<List<DataRow>>(
              future: getRowData(database, table),
              builder: (context, snapshotRows) {
                if (snapshotRows.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshotRows.hasError) {
                  return Text('Ошибка: ${snapshotRows.error}');
                } else if (snapshotRows.hasData) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: snapshotColumns.data!,
                        rows: snapshotRows.data!,
                      ),
                    ),
                  );
                } else {
                  return Text('Нет данных в таблице $table');
                }
              },
            );
          } else {
            return Text('Невозможно получить столбцы для таблицы $table');
          }
        },
      ),
    );
  }
}
