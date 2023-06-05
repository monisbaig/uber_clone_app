import 'package:flutter/material.dart';
import 'package:uber_clone_app/global_variables/global_variables.dart';
import 'package:uber_clone_app/screens/about_screen.dart';
import 'package:uber_clone_app/screens/profile_screen.dart';
import 'package:uber_clone_app/screens/splash_screen.dart';
import 'package:uber_clone_app/screens/trip_history_screen.dart';

class MyDrawer extends StatefulWidget {
  final String? name;
  final String? email;

  const MyDrawer({super.key, required this.name, required this.email});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            height: 165,
            color: Colors.lightBlueAccent,
            child: DrawerHeader(
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.email!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TripHistoryScreen(),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(
                Icons.history,
                color: Colors.blue,
              ),
              title: Text(
                'History',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.blue,
              ),
              title: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(
                Icons.info,
                color: Colors.blue,
              ),
              title: Text(
                'About',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              firebaseAuth.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MySplashScreen(),
                ),
              );
            },
            child: const ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.blue,
              ),
              title: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
