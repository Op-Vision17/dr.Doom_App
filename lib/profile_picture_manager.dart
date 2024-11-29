import 'dart:io';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePictureManager {
  final Box _profileBox = Hive.box('profileBox'); // Hive box to store profile data

  // Save the profile picture (file path or image in bytes)
  Future<void> saveProfilePicture(File imageFile) async {
    // Saving the image path in Hive
    await _profileBox.put('profile_picture', imageFile.path);

    // If you want to store the image in bytes instead, uncomment the following code
    // List<int> imageBytes = await imageFile.readAsBytes();
    // await _profileBox.put('profile_picture', imageBytes);
  }

  // Get the profile picture path from Hive
  Future<String?> getProfilePicturePath() async {
    return _profileBox.get('profile_picture'); // Retrieve the file path
  }

  // Function to allow the user to pick a profile picture
  Future<void> pickProfilePicture() async {
    final ImagePicker picker = ImagePicker();

    // Pick an image from the gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Save the selected image to Hive
      await saveProfilePicture(File(image.path));
    }
  }

  // This function returns the profile picture (file path) or a placeholder image if not set
  Future<File?> getProfilePictureFile() async {
    final String? imagePath = await getProfilePicturePath();

    if (imagePath != null) {
      return File(imagePath); // Return the image file from the saved path
    }

    return null; // Return null if no image is saved
  }
}
