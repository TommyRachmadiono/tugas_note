import 'package:flutter/material.dart';
import 'package:tugas_note/pages/edit_note_screen.dart';

class Note extends StatefulWidget {
  final list;
  final index;

  Note({this.list, this.index});

  @override
  _NoteState createState() => _NoteState();
}

class _NoteState extends State<Note> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditNoteScreen(note: widget.list[widget.index],),
          ),
        );
        setState(() {});
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.list[widget.index]["title"],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Divider(
                thickness: 2,
              ),
              Text(
                widget.list[widget.index]['message'] ?? '',
                maxLines: 7,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
