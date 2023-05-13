import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

// Event dan State untuk YourFirstCubit
abstract class YourFirstState {}

class YourFirstStateOne extends YourFirstState {}

class YourFirstStateTwo extends YourFirstState {}

// YourFirstCubit
class YourFirstCubit extends Cubit<YourFirstState> {
  // YourFirstCubit() : super(YourFirstStateOne());
  YourFirstCubit() : super(YourFirstStateOne()) {
    _fetchData();
  }
  dynamic _items = [];

  Future<void> _fetchData() async {
    final response =
        await http.get(Uri.parse('http://178.128.17.76:8000/daftar_umkm'));

    if (response.statusCode == 200) {
      // setState(() {
      _items = json.decode(response.body);
      List<dynamic> datas = _items['data'];
      _items = datas;
      emit(_items);
      return(_items);
      // });
    } else {
      throw Exception('Failed to load data');
    }
  }
}

// Event dan State untuk YourSecondCubit
abstract class YourSecondState {}

class YourSecondStateOne extends YourSecondState {}

class YourSecondStateTwo extends YourSecondState {}

// YourSecondCubit
class YourSecondCubit extends Cubit<YourSecondState> {
  YourSecondCubit() : super(YourSecondStateOne());

  void emitStateOne() => emit(YourSecondStateOne());

  void emitStateTwo() => emit(YourSecondStateTwo());
}

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<YourFirstCubit>(
          create: (_) => YourFirstCubit(),
        ),
        BlocProvider<YourSecondCubit>(
          create: (_) => YourSecondCubit(),
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
      title: 'Kuis 3 Provis Kelompok 7',
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
  int count = 0;

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
          title: Center(
            child: Text('App'),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text("2106515, " +
                  "Fachri Najm Noer Kartiman; " +
                  "2106238, " +
                  "Raisyad Jullfikar"),
            ),
            Container(
              child: Column(
                children: [
                  BlocBuilder<YourFirstCubit, YourFirstState>(
                    builder: (context, aktivitas) {
                      return Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    context.read<YourFirstCubit>()._fetchData();
                                    count++;
                                  });
                                },
                                child: Text("Reload Daftar UMKM"),
                              ),
                            ),
                          ]));
                    },
                  ),
                ],
              ),
            ),
            count == 0
                ? Center()
                : Expanded(
                    child: _items.isEmpty
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
                  ),
          ],
        ));
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
                  BlocBuilder<YourSecondCubit, YourSecondState>(
                    builder: (context, aktivitas) {
                      return Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text("Nama : " + _item['nama']),
                            Text("Detil : " + _item['jenis']),
                            Text("Member Sejak : " + _item['member_sejak']),
                            Text("Omzet Per Bulan : " + _item['omzet_bulan']),
                            Text("Lama Usaha : " + _item['lama_usaha']),
                            Text("Jumlah Pinjaman Sukses : " +
                                _item['jumlah_pinjaman_sukses']),
                          ]));
                    },
                  ),
                ],
              ),
      ),
    );
  }
}