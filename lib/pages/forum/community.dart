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
              author: doc['author'],
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
  final String author;
  final Timestamp timestamp;
  final String content;
  final VoidCallback onTap;

  const QuestionListItem({super.key, 
    required this.title,
    required this.author,
    required this.timestamp,
    required this.content,
    required this.onTap,
  });

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
                  Text(
                    author,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                    ),
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
                Text(
                  'Asked by ${questionData['author']} on ${DateFormat('MMM d, yyyy').format(questionData['timestamp'].toDate())}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
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
            var replyData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;

            // Handle the case where the timestamp might be null
            var timestamp = replyData['timestamp'] as Timestamp?;
            var formattedTimestamp = timestamp != null
                ? DateFormat('MMM d, yyyy').format(timestamp.toDate())
                : 'Unknown date';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(replyData['text']),
                    const SizedBox(height: 4.0),
                    Text(
                      'Replied by ${replyData['author']} on $formattedTimestamp',
                      style: const TextStyle(color: Colors.grey),
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
}
