import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

// Event untuk YourFirstBloc
abstract class YourFirstEvent {}

class YourFirstEventOne extends YourFirstEvent {}

class YourFirstEventTwo extends YourFirstEvent {}

// State untuk YourFirstBloc
abstract class YourFirstState {}

class YourFirstStateOne extends YourFirstState {}

class YourFirstStateTwo extends YourFirstState {}

// YourFirstBloc
class YourFirstBloc extends Bloc<YourFirstEvent, YourFirstState> {
  YourFirstBloc() : super(YourFirstStateOne());

  @override
  Stream<YourFirstState> mapEventToState(YourFirstEvent event) async* {
    if (event is YourFirstEventOne) {
      yield YourFirstStateOne();
    } else if (event is YourFirstEventTwo) {
      yield YourFirstStateTwo();
    }
  }
}

// Event untuk YourSecondBloc
abstract class YourSecondEvent {}

class YourSecondEventOne extends YourSecondEvent {}

class YourSecondEventTwo extends YourSecondEvent {}

// State untuk YourSecondBloc
abstract class YourSecondState {}

class YourSecondStateOne extends YourSecondState {}

class YourSecondStateTwo extends YourSecondState {}

// YourSecondBloc
class YourSecondBloc extends Bloc<YourSecondEvent, YourSecondState> {
  YourSecondBloc() : super(YourSecondStateOne());

  @override
  Stream<YourSecondState> mapEventToState(YourSecondEvent event) async* {
    if (event is YourSecondEventOne) {
      yield YourSecondStateOne();
    } else if (event is YourSecondEventTwo) {
      yield YourSecondStateTwo();
    }
  }
}

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<YourFirstBloc>(
          create: (_) => YourFirstBloc(),
        ),
        BlocProvider<YourSecondBloc>(
          create: (_) => YourSecondBloc(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Card and Routing Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  dynamic _items = [];

  Future<void> _fetchData() async {
    final response =
        await http.get(Uri.parse('http://178.128.17.76:8000/daftar_umkm'));

    if (response.statusCode == 200) {
      setState(() {
        _items = json.decode(response.body);
        List<dynamic> datas = _items['data'];
        _items = datas;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: _items.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(_items[index]['nama']),
                    subtitle: Text(_items[index]['jenis']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            id: _items[index]['id'],
                            title: _items[index]['nama'],
                            message: _items[index]['jenis'],
                          ),
                        ),
                      );
                    },
                    leading: Image.network(
                        'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                    trailing: const Icon(Icons.more_vert),
                    tileColor: Colors.white,
                  ),
                );
              },
            ),
    );
  }
}

class DetailPage extends StatefulWidget {
  final String id;
  final String title;
  final String message;

  const DetailPage(
      {Key? key, required this.id, required this.title, required this.message})
      : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic> _item = {};

  Future<void> _fetchData() async {
    final response = await http
        .get(Uri.parse('http://178.128.17.76:8000/detil_umkm/${widget.id}'));
    if (response.statusCode == 200) {
      setState(() {
        _item = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _item.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Text("Nama : " + _item['nama']),
                  Text("Detil : " + _item['jenis']),
                  Text("Member Sejak : " + _item['member_sejak']),
                  Text("Omzet Per Bulan : " + _item['omzet_bulan']),
                  Text("Lama Usaha : " + _item['lama_usaha']),
                  Text("Jumlah Pinjaman Sukses : " +
                      _item['jumlah_pinjaman_sukses']),
                  // Text(widget.id),
                ],
              ),
      ),
    );
  }
}
