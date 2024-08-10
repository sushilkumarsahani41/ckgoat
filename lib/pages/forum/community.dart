import 'package:ckgoat/pages/forum/addquestion.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForumPage extends StatefulWidget {
  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forum'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: QuestionList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddQuestionPage()),
          );
        },
      ),

      backgroundColor: Colors.grey[100], // Light grey background
    );
  }
}

class QuestionList extends StatefulWidget {
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
          return Center(child: CircularProgressIndicator());
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

  QuestionListItem({
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
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                content,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
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

  QuestionViewScreen({required this.questionId});

  @override
  State<QuestionViewScreen> createState() => _QuestionViewScreenState();
}

class _QuestionViewScreenState extends State<QuestionViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Question'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: [
          QuestionDetails(questionId: widget.questionId),
          Expanded(child: ReplyList(questionId: widget.questionId)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.reply),
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          _showReplyDialog(context, widget.questionId);
        },
      ),
    );
  }

  void _showReplyDialog(BuildContext context, String questionId) {
    showDialog(
      context: context,
      builder: (context) {
        final _formKey = GlobalKey<FormState>();
        final _contentController = TextEditingController();
        String? _userUid;

        Future<void> _loadUserUid() async {
          final prefs = await SharedPreferences.getInstance();
          _userUid = prefs.getString('uid');
        }

        Future<void> _submitReply() async {
          if (_formKey.currentState!.validate() && _userUid != null) {
            await FirebaseFirestore.instance
                .collection('forum')
                .doc(questionId)
                .collection('replies')
                .add({
              'text': _contentController.text,
              'author': _userUid,
              'timestamp': FieldValue.serverTimestamp(),
            });

            Navigator.pop(context);
          }
        }

        _loadUserUid();

        return AlertDialog(
          title: Text('Add Reply'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
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
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: _submitReply,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.deepOrange,
              ),
            ),
          ],
        );
      },
    );
  }
}

class QuestionDetails extends StatefulWidget {
  final String questionId;

  QuestionDetails({required this.questionId});

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
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        var questionData = snapshot.data!.data() as Map<String, dynamic>;

        return Card(
          margin: EdgeInsets.all(8.0),
          color: Colors.blue[50], // Light blue background for question
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionData['title'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  questionData['content'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.0),
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

  ReplyList({required this.questionId});

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
          return Center(child: CircularProgressIndicator());
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
              margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(replyData['text']),
                    SizedBox(height: 4.0),
                    Text(
                      'Replied by ${replyData['author']} on $formattedTimestamp',
                      style: TextStyle(color: Colors.grey),
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
