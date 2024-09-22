import 'package:ckgoat/pages/forum/addquestion.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: const QuestionList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddQuestionPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.grey[100], // Light grey background
    );
  }
}

class QuestionList extends StatefulWidget {
  const QuestionList({super.key});

  @override
  State<QuestionList> createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('forum')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snapshot.data!.docs[index];
            return QuestionListItem(
              title: doc['title'],
              author: doc['author'], // This is the user ID
              timestamp: doc['timestamp'],
              content: doc['content'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuestionViewScreen(questionId: doc.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class QuestionListItem extends StatelessWidget {
  final String title;
  final String author; // This is the user ID
  final Timestamp timestamp;
  final String content;
  final VoidCallback onTap;

  const QuestionListItem({
    super.key,
    required this.title,
    required this.author,
    required this.timestamp,
    required this.content,
    required this.onTap,
  });

  // Fetch the full name based on the author (userId)
  Future<String> _getAuthorName(String authorId) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(authorId)
        .get();

    if (userSnapshot.exists) {
      return userSnapshot['name']; // Return the full name from the 'name' field
    }
    return 'Unknown Author'; // If user data is not found
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder<String>(
                    future: _getAuthorName(author), // Fetch the name field
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading...'); // While fetching
                      } else if (snapshot.hasError) {
                        return const Text('Error'); // Handle error
                      } else {
                        return Text(
                          snapshot.data ?? 'Unknown Author',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        );
                      }
                    },
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(timestamp.toDate()),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionViewScreen extends StatefulWidget {
  final String questionId;

  const QuestionViewScreen({super.key, required this.questionId});

  @override
  State<QuestionViewScreen> createState() => _QuestionViewScreenState();
}

class _QuestionViewScreenState extends State<QuestionViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          QuestionDetails(questionId: widget.questionId),
          Expanded(child: ReplyList(questionId: widget.questionId)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          _showReplyDialog(context, widget.questionId);
        },
        child: const Icon(Icons.reply),
      ),
    );
  }

  void _showReplyDialog(BuildContext context, String questionId) {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        final contentController = TextEditingController();
        String? userUid;

        Future<void> loadUserUid() async {
          final prefs = await SharedPreferences.getInstance();
          userUid = prefs.getString('uid');
        }

        Future<void> submitReply() async {
          if (formKey.currentState!.validate() && userUid != null) {
            await FirebaseFirestore.instance
                .collection('forum')
                .doc(questionId)
                .collection('replies')
                .add({
              'text': contentController.text,
              'author': userUid,
              'timestamp': FieldValue.serverTimestamp(),
            });

            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          }
        }

        loadUserUid();

        return AlertDialog(
          title: const Text('Add Reply'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Reply',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your reply';
                }
                return null;
              },
              maxLines: 3,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              onPressed: submitReply,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepOrange,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

class QuestionDetails extends StatefulWidget {
  final String questionId;

  const QuestionDetails({super.key, required this.questionId});

  @override
  State<QuestionDetails> createState() => _QuestionDetailsState();
}

class _QuestionDetailsState extends State<QuestionDetails> {
  // Fetch the full name based on the author (userId)
  Future<String> _getAuthorName(String authorId) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(authorId)
        .get();

    if (userSnapshot.exists) {
      return userSnapshot['name']; // Return the full name from the 'name' field
    }
    return 'Unknown Author'; // If user data is not found
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('forum')
          .doc(widget.questionId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var questionData = snapshot.data!.data() as Map<String, dynamic>;
        var authorId = questionData['author']; // This is the user ID

        return Card(
          margin: const EdgeInsets.all(8.0),
          color: Colors.blue[50], // Light blue background for question
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionData['title'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  questionData['content'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8.0),
                FutureBuilder<String>(
                  future: _getAuthorName(authorId), // Fetch the name field
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Loading author...');
                    } else if (snapshot.hasError) {
                      return const Text('Error fetching author');
                    } else {
                      return Text(
                        'Asked by ${snapshot.data ?? 'Unknown Author'} on ${DateFormat('MMM d, yyyy').format(questionData['timestamp'].toDate())}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ReplyList extends StatefulWidget {
  final String questionId;

  const ReplyList({super.key, required this.questionId});

  @override
  State<ReplyList> createState() => _ReplyListState();
}

class _ReplyListState extends State<ReplyList> {
  String? loggedInUserId;

  @override
  void initState() {
    super.initState();
    _getLoggedInUser();
  }

  // Get the logged-in user's ID from shared preferences
  Future<void> _getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInUserId = prefs
          .getString('uid'); // Assuming 'uid' is stored for the logged-in user
    });
  }

  // Fetch the full name based on the author (userId)
  Future<String> _getAuthorName(String authorId) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(authorId)
        .get();

    if (userSnapshot.exists) {
      return userSnapshot['name']; // Return the full name from the 'name' field
    }
    return 'Unknown Author'; // If user data is not found
  }

  // Delete a reply by its document ID
  Future<void> _deleteReply(String questionId, String replyId) async {
    await FirebaseFirestore.instance
        .collection('forum')
        .doc(questionId)
        .collection('replies')
        .doc(replyId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('forum')
          .doc(widget.questionId)
          .collection('replies')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var replyDoc = snapshot.data!.docs[index];
            var replyData = replyDoc.data() as Map<String, dynamic>;
            var replyId = replyDoc.id;
            var authorId = replyData['author'];

            // Handle the case where the timestamp might be null
            var timestamp = replyData['timestamp'] as Timestamp?;
            var formattedTimestamp = timestamp != null
                ? DateFormat('MMM d, yyyy').format(timestamp.toDate())
                : 'Unknown date';

            return Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          replyData['text'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (authorId == loggedInUserId)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmationDialog(context, replyId);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    FutureBuilder<String>(
                      future: _getAuthorName(
                          authorId), // Fetch full name from 'author'
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Loading...');
                        } else if (snapshot.hasError) {
                          return const Text('Error');
                        } else {
                          return Text(
                            'Replied by ${snapshot.data ?? 'Unknown Author'} on $formattedTimestamp',
                            style: const TextStyle(color: Colors.grey),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Show a confirmation dialog before deleting the reply
  void _showDeleteConfirmationDialog(BuildContext context, String replyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Reply'),
          content: const Text('Are you sure you want to delete this reply?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteReply(widget.questionId, replyId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
