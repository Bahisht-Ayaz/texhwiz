
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(const ashow());
}

class ashow extends StatelessWidget {
  const ashow({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  void deletedata(String demoid) {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      db.collection("Pets").doc(demoid).delete();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Record Deleted")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  void update_record(String id, String n, String a, String b, String g, String p) {
    try {
      db.collection("Pets").doc(id).update({
        "Name": n,
        "Age": a,
        "Breed": b,
        "Gender": g,
        "Photo": p,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Record Updated")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  void update_dialog(
      BuildContext con, String id, String n, String a, String b, String g, String p) {
    TextEditingController name = TextEditingController(text: n);
    TextEditingController age = TextEditingController(text: a);
    TextEditingController breed = TextEditingController(text: b);
    TextEditingController gender = TextEditingController(text: g);
    TextEditingController photo = TextEditingController(text: p);
    showDialog(
        context: con,
        builder: (a) => AlertDialog(
              title: Text("Update Record"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: 300),
                    margin: EdgeInsets.all(10),
                    child: TextField(
                      controller: name,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person),
                      ),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: 300),
                    margin: EdgeInsets.all(10),
                    child: TextField(
                      controller: age,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.number),
                      ),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: 300),
                    margin: EdgeInsets.all(10),
                    child: TextField(
                      controller: breed,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.abc),
                      ),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: 300),
                    margin: EdgeInsets.all(10),
                    child: TextField(
                      controller: gender,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person),
                      ),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: 300),
                    margin: EdgeInsets.all(10),
                    child: TextField(
                      controller: photo,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.photo),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton.icon(
                    onPressed: () {
                      update_record(
                          id, name.text, description.text, image.text);
                      Navigator.of(con, rootNavigator: true).pop();
                    },
                    label: Text("Yes"),
                    icon: Icon(Icons.check)),
                TextButton.icon(
                    onPressed: () {
                      Navigator.of(con, rootNavigator: true).pop();
                    },
                    label: Text("No"),
                    icon: Icon(Icons.close)),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (builder) => Pets()),
            );
          },
        ),
        backgroundColor: Color(0xFF1E88E5),
        elevation: 4,
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: db.collection("Pets").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Text("No Data"),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Error"),
              );
            }

            var datalao = snapshot.data!.docs;

            return ListView.builder(
              itemCount: datalao.length,
              itemBuilder: (context, i) {
                var mydata = datalao[i].data() as Map<String, dynamic>;
                String U_id = datalao[i].id;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(
                      mydata["Name"] ?? "No Data",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mydata["Age"] ?? "No Age",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          Text(
                            mydata["Breed"] ?? "No Breed",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          Text(
                            mydata["Gender"] ?? "No Gender",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            mydata["Photo"] ?? "No Image",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            update_dialog(context, U_id, mydata["Name"],
                                mydata["Age"], mydata["Breed"],mydata["Gender"],mydata["Photo"]);
                          },
                          icon: Icon(
                            Icons.edit,
                            color: Colors.green,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (builder) => AlertDialog(
                                title: Text("Delete Record"),
                                content: Text(
                                    "Are you sure you want to delete this record?"),
                                actions: [
                                  TextButton.icon(
                                    onPressed: () {
                                      deletedata(U_id);
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    },
                                    label: Text("Yes"),
                                    icon: Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    },
                                    label: Text("No"),
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}