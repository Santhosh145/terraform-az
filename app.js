const express = require('express');
const fs = require('fs');
const path = require('path');
const app = express();
const PORT = 3000;
const NOTES_FILE = path.join(__dirname, 'notes.txt');

app.use(express.static('public'));
app.use(express.json());

// API to get notes
app.get('/api/notes', (req, res) => {
  let notes = '';
  if (fs.existsSync(NOTES_FILE)) {
    notes = fs.readFileSync(NOTES_FILE, 'utf8');
  }
  res.send(notes);
});

// API to save notes
app.post('/api/notes', (req, res) => {
  fs.writeFileSync(NOTES_FILE, req.body.notes || '');
  res.send('Notes saved!');
});

app.listen(PORT, () => {
  console.log(`Notepad app running at http://localhost:${PORT}`);
});