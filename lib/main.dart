import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Record {
  final String name;
  final String icon;
  final double quarter;
  final double half;
  final double full;
  final bool favourite;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
     : assert(map['name'] != null),
       assert(map['quarter'] != null),
       assert(map['icon'] != null),
       assert(map['half'] != null),
       assert(map['full'] != null),
       name = map['name'],
       icon = map['icon'],
       favourite = map['favourite'],
       quarter = map['quarter'].toDouble(),
       half = map['half'].toDouble(),
       full = map['full'].toDouble();

 Record.fromSnapshot(DocumentSnapshot snapshot)
     : this.fromMap(snapshot.data, reference: snapshot.reference);

 @override
 String toString() => "Record<$name:$quarter:$half:$full:$favourite>";
}
class RecordDataSource extends DataTableSource {
  final List<Record> _records =[];
  RecordDataSource(){
    Firestore.instance.collection("banks").orderBy('name', descending: false).getDocuments()
      .then((QuerySnapshot snapshot) {
        snapshot.documents.forEach((doc) =>{
          _records.add(Record.fromSnapshot(doc))
        });
    });
  }
  void _sort<T>(Comparable<T> getField(Record d), bool ascending) {
    _records.sort((Record a, Record b) {
      if (!ascending) {
        final Record c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _records.length)
      return null;
    final Record record = _records[index];
    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(Text('${record.name}')),
        DataCell(Text(record.quarter!=-1 ? '${record.quarter}' : '-')),
        DataCell(Text(record.half!=-1 ? '${record.half}' : '-')),
        DataCell(Text(record.full!=-1 ? '${record.full}' : '-')),
      ],
    );
  }

  @override
  int get rowCount => _records.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
void main() {
  runApp(MyApp());
}
class FullRating extends StatelessWidget {
  final RecordDataSource _recordsDataSource = RecordDataSource();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lãi Suất Tiết Kiệm"),
      ),
      body: Center(
        child: _buildBanksTab(context),
      ),
    );
  }
  Widget _buildBanksTab(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[DataTable(                  
                  sortColumnIndex: 0,
                  sortAscending: true,
                  rows:<DataRow>[new DataRow(cells: <DataCell>[
                    DataCell(Text("test")),
                    DataCell(Text("test")),
                    DataCell(Text("test")),
                    DataCell(Text("test")),
                    DataCell(Text("test")),
                    DataCell(Text("test")),
                  ],
                    )],
                  columns: <DataColumn>[
          DataColumn(
            label: Text('Bank',style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: false,
            //onSort: (int columnIndex, bool ascending) => _sort<String>((Record d) => d.name, columnIndex, ascending),
          ),
          DataColumn(
            label: Text('3T',style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
            //onSort: (int columnIndex, bool ascending) => _sort<num>((Record d) => d.quarter, columnIndex, ascending),
          ),
          DataColumn(
            label: Text('6T',style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
            //onSort: (int columnIndex, bool ascending) => _sort<num>((Record d) => d.half, columnIndex, ascending),            
          ),
          DataColumn(
            label: Text('12T',style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
            //onSort: (int columnIndex, bool ascending) => _sort<num>((Record d) => d.full, columnIndex, ascending),
          ),
        ],
              )]
                  
                                 /*FlatButton(
        onPressed: () {
          /*...*/
        },
        child: Text(
          "Mở Rộng",
          style: TextStyle(fontSize: 20.0),
        ),
      ),*///const Text('Banks'),

      /* columns: <DataColumn>[
          DataColumn(
            label: Text('Bank',style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: false,
            onSort: (int columnIndex, bool ascending) => _sort<String>((Record d) => d.name, columnIndex, ascending),
          ),
          DataColumn(
            label: Text('3T',style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
            onSort: (int columnIndex, bool ascending) => _sort<num>((Record d) => d.quarter, columnIndex, ascending),
          ),
          DataColumn(
            label: Text('6T',style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
            onSort: (int columnIndex, bool ascending) => _sort<num>((Record d) => d.half, columnIndex, ascending),            
          ),
          DataColumn(
            label: Text('12T',style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
            onSort: (int columnIndex, bool ascending) => _sort<num>((Record d) => d.full, columnIndex, ascending),
          ),
        ],
      source:  _recordsDataSource,   */  
    );    
 }
}
class MyApp extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
   return MaterialApp(
     title: 'Smart Banks',
     home: MyHomePage(),
   );
 }
}

class MyHomePage extends StatefulWidget {
 @override
 _MyHomePageState createState() {
   return _MyHomePageState();
 }
}

class _MyHomePageState extends State<MyHomePage> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex=0;
  bool _sortAscending = true;
  final RecordDataSource _recordsDataSource = RecordDataSource();
  void _sort<T>(Comparable<T> getField(Record d), int columnIndex, bool ascending) {
    _recordsDataSource._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }
 @override
 Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.monetization_on)),
                Tab(icon: Icon(Icons.table_chart)),
                Tab(icon: Icon(Icons.settings)),
              ],
            ),
            title: Text('Banks'),
          ),
          body: TabBarView(
            children: [
              _buildBanksTab(context),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildBanksTab(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[PaginatedDataTable( 
      header: Container(
                  color: Colors.grey.withOpacity(.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text("Lãi Suất Tiết Kiệm",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          )),
                      FlatButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FullRating()),
          );
        },
        child: Text(
          "Mở Rộng",
          style: TextStyle(fontSize: 20.0),
        ),
      ),
                    ],
                  ),
                  padding: EdgeInsets.all(10.0),
                ),/*FlatButton(
        onPressed: () {
          /*...*/
        },
        child: Text(
          "Mở Rộng",
          style: TextStyle(fontSize: 20.0),
        ),
      ),*///const Text('Banks'),
      rowsPerPage: _rowsPerPage,
      onRowsPerPageChanged: (int value) { setState(() { _rowsPerPage = value; }); },
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: <DataColumn>[
          DataColumn(
            label: Text('Bank',style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: false,
            onSort: (int columnIndex, bool ascending) => _sort<String>((Record d) => d.name, columnIndex, ascending),
          ),
          DataColumn(
            label: Text('3T',style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
            onSort: (int columnIndex, bool ascending) => _sort<num>((Record d) => d.quarter, columnIndex, ascending),
          ),
          DataColumn(
            label: Text('6T',style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
            onSort: (int columnIndex, bool ascending) => _sort<num>((Record d) => d.half, columnIndex, ascending),            
          ),
          DataColumn(
            label: Text('12T',style: TextStyle(fontWeight: FontWeight.bold)),
            numeric: true,
            onSort: (int columnIndex, bool ascending) => _sort<num>((Record d) => d.full, columnIndex, ascending),
          ),
        ],
      source:  _recordsDataSource,    
    )]);    
 }

}