import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctor_doom/services/user_storage.dart';

// Model
class Profile {
  final String name;
  final String email;
  final String phoneNumber;
  final String? profilePicture;

  Profile({
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
  });
}


final profileProvider = FutureProvider<Profile>((ref) async {
  final userStorage = UserStorage();
  final userData = await userStorage.getUserData();

  return Profile(
    name: '${userData['first_name']} ${userData['last_name']}',
    email: userData['email'] ?? '',
    phoneNumber: userData['phone_number'] ?? '',
    profilePicture: userData['profile_picture'] ?? null,
  );
});

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      body: Stack(
        children: [
        
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/loginbackground.jpg'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
        
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60), 
                  
                  profileAsync.when(
                    data: (profile) {
                      return Column(
                        children: [
                    
                          CircleAvatar(
                            radius: 60,
                            child: Icon(Icons.person, size: 60),
                          ),
                          const SizedBox(height: 20),
                    
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              
                                Text(
                                  'Name: ${profile.name}',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                            
                                Text(
                                  'Email: ${profile.email}',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 16),
                              
                                Text(
                                  'Phone Number: ${profile.phoneNumber}',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () {
                      return const Center(child: CircularProgressIndicator());
                    },
                    error: (error, stackTrace) {
                      return Center(child: Text('Error: $error'));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfilePage(),
    );
  }
}
