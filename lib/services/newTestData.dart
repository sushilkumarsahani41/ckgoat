import 'package:cloud_firestore/cloud_firestore.dart';

void pushSampleDataToFirebase() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> questions = [
    {
      "id": "q1",
      "title": "How to implement state management in Flutter?",
      "content":
          "I'm new to Flutter and I'm confused about the best way to manage state in my app. Should I use setState, Provider, or BLoC? What are the pros and cons of each approach?",
      "author": "FlutterNewbie",
      "timestamp": Timestamp.fromDate(DateTime.parse("2024-08-01T10:30:00Z")),
      "replies": [
        {
          "text":
              "For small apps, setState is fine. For medium-sized apps, Provider is great. For large, complex apps, consider BLoC or Redux.",
          "author": "FlutterPro",
          "timestamp":
              Timestamp.fromDate(DateTime.parse("2024-08-01T11:15:00Z")),
        },
        {
          "text":
              "I personally prefer Provider for most cases. It's simple to use and understand, yet powerful enough for most apps.",
          "author": "DartLover",
          "timestamp":
              Timestamp.fromDate(DateTime.parse("2024-08-01T12:00:00Z")),
        }
      ]
    },
    {
      "id": "q2",
      "title": "Best practices for Firebase security rules?",
      "content":
          "I'm setting up a Firebase project and I want to ensure my data is secure. What are some best practices for writing Firebase security rules?",
      "author": "SecurityMinded",
      "timestamp": Timestamp.fromDate(DateTime.parse("2024-08-02T09:00:00Z")),
      "replies": [
        {
          "text":
              "Always start with denying all read/write operations, then gradually allow specific operations based on user authentication and data validation.",
          "author": "FirebaseExpert",
          "timestamp":
              Timestamp.fromDate(DateTime.parse("2024-08-02T09:30:00Z")),
        }
      ]
    },
    {
      "id": "q3",
      "title": "How to implement push notifications in Flutter?",
      "content":
          "I want to add push notifications to my Flutter app. What's the best way to do this? Are there any good packages or services you'd recommend?",
      "author": "NotificationNovice",
      "timestamp": Timestamp.fromDate(DateTime.parse("2024-08-03T14:00:00Z")),
      "replies": [
        {
          "text":
              "Firebase Cloud Messaging (FCM) is a great option. It's free and integrates well with Flutter. Check out the 'firebase_messaging' package.",
          "author": "PushPro",
          "timestamp":
              Timestamp.fromDate(DateTime.parse("2024-08-03T14:30:00Z")),
        }
      ]
    },
    {
      "id": "q4",
      "title": "Flutter vs React Native in 2024",
      "content":
          "I'm starting a new mobile project and I'm torn between Flutter and React Native. How do they compare in 2024? Which one would you recommend for a cross-platform app?",
      "author": "CrossPlatformCurious",
      "timestamp": Timestamp.fromDate(DateTime.parse("2024-08-04T11:00:00Z")),
      "replies": [
        {
          "text":
              "Both are great choices, but Flutter has been gaining more traction lately. It offers better performance and a more consistent UI across platforms.",
          "author": "MobileDev",
          "timestamp":
              Timestamp.fromDate(DateTime.parse("2024-08-04T11:30:00Z")),
        },
        {
          "text":
              "If you're already familiar with JavaScript, React Native might be easier to pick up. But long-term, I think Flutter has more potential.",
          "author": "TechAnalyst",
          "timestamp":
              Timestamp.fromDate(DateTime.parse("2024-08-04T12:00:00Z")),
        }
      ]
    },
    {
      "id": "q5",
      "title": "Best practices for Flutter app architecture",
      "content":
          "I'm starting a new Flutter project and want to ensure it's scalable and maintainable. What are some best practices for structuring a Flutter app?",
      "author": "ArchitectureEnthusiast",
      "timestamp": Timestamp.fromDate(DateTime.parse("2024-08-05T15:00:00Z")),
      "replies": [
        {
          "text":
              "Consider using a layered architecture like Clean Architecture or MVVM. Separate your UI, business logic, and data layers.",
          "author": "CodeStructurer",
          "timestamp":
              Timestamp.fromDate(DateTime.parse("2024-08-05T15:30:00Z")),
        }
      ]
    },
    {
      "id": "q6",
      "title": "How to optimize Flutter app performance?",
      "content":
          "My Flutter app is running a bit slow, especially on older devices. What are some ways to optimize its performance?",
      "author": "PerformanceSeeker",
      "timestamp": Timestamp.fromDate(DateTime.parse("2024-08-06T13:00:00Z")),
      "replies": [
        {
          "text":
              "Use const constructors where possible, implement proper list view builders, and avoid unnecessary rebuilds. Also, profile your app to identify bottlenecks.",
          "author": "OptimizationGuru",
          "timestamp":
              Timestamp.fromDate(DateTime.parse("2024-08-06T13:30:00Z")),
        }
      ]
    },
    {
      "id": "q7",
      "title": "Flutter web vs traditional web frameworks",
      "content":
          "How does Flutter for web compare to traditional web frameworks like React or Angular in 2024? Is it a viable option for web development?",
      "author": "WebDeveloper",
      "timestamp": Timestamp.fromDate(DateTime.parse("2024-08-07T10:00:00Z")),
      "replies": [
        {
          "text":
              "Flutter web has improved significantly, but it's still best suited for app-like experiences rather than content-heavy websites. Traditional frameworks are still preferred for most web projects.",
          "author": "WebExpert",
          "timestamp":
              Timestamp.fromDate(DateTime.parse("2024-08-07T10:30:00Z")),
        }
      ]
    },
    {
      "id": "q8",
      "title": "How to implement in-app purchases in Flutter?",
      "content":
          "I want to add in-app purchases to my Flutter app. What's the best way to do this for both iOS and Android?",
      "author": "MonetizationMinded",
      "timestamp": Timestamp.fromDate(DateTime.parse("2024-08-08T16:00:00Z")),
      "replies": [
        {
          "text":
              "Check out the 'in_app_purchase' package. It provides a unified API for in-app purchases on both platforms and handles a lot of the complexity for you.",
          "author": "RevenueExpert",
          "timestamp":
              Timestamp.fromDate(DateTime.parse("2024-08-08T16:30:00Z")),
        }
      ]
    },
    {
      "id": "q9",
      "title": "Flutter testing best practices",
      "content":
          "I want to improve the test coverage of my Flutter app. What are some best practices for writing and organizing tests in Flutter?",
      "author": "TestingNewbie",
      "timestamp": Timestamp.fromDate(DateTime.parse("2024-08-09T11:00:00Z")),
      "replies": [
        {
          "text":
              "Start with unit tests for your business logic, then add widget tests for your UI components. Use integration tests for critical user flows. The 'flutter_test' package is your friend!",
          "author": "TestMaster",
          "timestamp":
              Timestamp.fromDate(DateTime.parse("2024-08-09T11:30:00Z")),
        }
      ]
    },
    {
      "id": "q10",
      "title": "Flutter vs native development in 2024",
      "content":
          "How does Flutter compare to native development (Swift/Kotlin) in 2024? Are there still significant advantages to going native?",
      "author": "PlatformPonderer",
      "timestamp": Timestamp.fromDate(DateTime.parse("2024-08-10T14:00:00Z")),
      "replies": [
        {
          "text":
              "Flutter has closed the gap significantly. It offers near-native performance and a rich set of customizable widgets. Native still has an edge for platform-specific features and absolute best performance, but Flutter is sufficient for most apps.",
          "author": "CrossPlatformConvert",
          "timestamp":
              Timestamp.fromDate(DateTime.parse("2024-08-10T14:30:00Z")),
        },
        {
          "text":
              "If you need to support both platforms and have limited resources, Flutter is a great choice. For platform-specific apps or those requiring deep OS integration, native might still be preferable.",
          "author": "MobileMastermind",
          "timestamp":
              Timestamp.fromDate(DateTime.parse("2024-08-10T15:00:00Z")),
        }
      ]
    }
  ];

  for (var question in questions) {
    try {
      // Extract replies from the question data
      List<Map<String, dynamic>> replies =
          List<Map<String, dynamic>>.from(question['replies']);
      question.remove('replies');

      // Add the question document
      DocumentReference questionRef =
          await firestore.collection('forum').add(question);

      // Add replies as a subcollection
      for (var reply in replies) {
        await questionRef.collection('replies').add(reply);
      }

      print('Added question: ${question['title']}');
    } catch (e) {
      print('Error adding question: ${question['title']}');
      print(e);
    }
  }

  print('Finished adding sample data to Firebase');
}
