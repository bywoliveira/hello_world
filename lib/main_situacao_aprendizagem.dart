import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Meu cartão")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Container de cima
               Container(
               width: 350,
              height: 240,
              padding: EdgeInsets.all(8),  
            decoration: BoxDecoration(
            color: const Color.fromARGB(255, 87, 8, 101), 
              borderRadius: BorderRadius.circular(10), 
            ),
           
           
            child :
             Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
            Text(
            "Banco sesi/senai", 
             style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 90),
              Text(
              "1234 5678",
              style: TextStyle(color: Colors.white)
              ),
             
                Column (
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                SizedBox(width: 40),
                Icon(Icons.contactless, size: 30, color: const Color.fromARGB(255, 239, 235, 234)),
                
                SizedBox(height: 35),

                Icon(Icons.sim_card, size: 30, color: const Color.fromARGB(255, 239, 235, 234)),

                
                  ],
                ),
                
                    ],           
                  )
               ),
            ]
      
          )
        ),
      ),
    );
  }
}
