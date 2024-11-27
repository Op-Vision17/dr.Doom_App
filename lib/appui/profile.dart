import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//   Model
class Profile {
  final String name;
  final String email;
  final String profilePicture;

  Profile({
    required this.name,
    required this.email,
    required this.profilePicture,
  });
}

// Provider
final profileProvider = StateProvider<Profile>((ref) {
  return Profile(
    name: 'John Doe',
    email: 'johndoe@example.com',
    profilePicture: 'https://via.placeholder.com/150',
  );
});

class ProfilePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the profile state from the provider
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profile.profilePicture),
            ),
            SizedBox(height: 16),
            Text(
              'Name: ${profile.name}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Email: ${profile.email}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Example: Update profile data
                ref.read(profileProvider.notifier).state = Profile(
                  name: 'Jane Doe',
                  email: 'janedoe@example.com',
                  profilePicture: 'https://via.placeholder.com/150',
                );
              },
              child: Text('Update Profile'),
            ),
          ],
        ),
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
