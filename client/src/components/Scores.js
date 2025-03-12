import React, { useState, useEffect } from "react";
import { useDropzone } from 'react-dropzone';
import { api } from '../config';

const ScoresPage = () => {
  const [scores, setScores] = useState([]);
  const [newScore, setNewScore] = useState("");
  const [selectedPlayers, setSelectedPlayers] = useState([null, null, null, null]);
  const [playerScores, setPlayerScores] = useState(["", "", "", ""]);
  const [files, setFiles] = useState([]);
  const [users, setUsers] = useState([]);

  useEffect(() => {
    // Fetch all users
    const fetchUsers = async () => {
      try {
        const response = await api.get('/users');
        setUsers(response.data);
      } catch (error) {
        console.error("Error fetching users:", error);
      }
    };

    fetchUsers();
  }, []);

  // useEffect(() => {
  //   // Fetch all scores
  //   const fetchScores = async () => {
  //     try {
  //       const response = await api.get('/scores');
  //       setScores(response.data);
  //     } catch (error) {
  //       console.error("Error fetching scores:", error);
  //     }
  //   };

  //   fetchScores();
  // }, []);

  const handleScoreSubmit = async () => {
    // Ensure at least one player is selected and has a score
    if (!selectedPlayers.some(player => player) || !playerScores.some(score => score)) return;

    // Prepare data for submission
    const formData = new FormData();
    formData.append('eventid', '1'); // Example event ID, replace with actual event ID
    formData.append('userids', selectedPlayers.filter(player => player).join(','));
    if (files[0]) {
      formData.append('scoreimage', files[0]);
    }

    try {
      const response = await api.post('/scores', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });
      console.log("Scores submitted:", response.data);
      alert("Scores submitted for approval!");
      setScores([...scores, ...response.data.scores]);
    } catch (error) {
      console.error("Error submitting scores:", error);
    }

    // Reset form
    setSelectedPlayers([null, null, null, null]);
    setPlayerScores(["", "", "", ""]);
    setFiles([]);
  };

  const onDrop = (acceptedFiles) => {
    setFiles(acceptedFiles);
  };

  const { getRootProps, getInputProps } = useDropzone({
    onDrop,
    accept: 'image/*',
  });

  const handlePlayerChange = (index, value) => {
    const updatedPlayers = [...selectedPlayers];
    updatedPlayers[index] = value;
    setSelectedPlayers(updatedPlayers);
  };

  const handlePlayerScoreChange = (index, value) => {
    const updatedScores = [...playerScores];
    updatedScores[index] = value;
    setPlayerScores(updatedScores);
  };

  return (
    <div className="bg-gray-100 min-h-screen">
      <header className="bg-black text-gold p-6 shadow-md">
        <h1 className="text-3xl font-bold text-center">Submit Qualifying Scores</h1>
      </header>
      <main className="max-w-4xl mx-auto p-6">
        <div className="mb-6">
          <h2 className="text-2xl font-semibold">Your Submitted Scores</h2>
          <ul className="space-y-4 mt-4">
            {scores.map((score) => (
              <li
                key={score.id}
                className="bg-white p-4 shadow rounded-lg border border-gray-200"
              >
                Score: {score.score}
              </li>
            ))}
          </ul>
        </div>
        <div className="bg-white p-6 shadow rounded-lg border border-gray-200">
          <h2 className="text-xl font-bold mb-4">Submit a New Score</h2>
          <div {...getRootProps({ className: 'dropzone' })} className="border-dashed border-2 border-gray-300 p-4 mb-4">
            <input {...getInputProps()} />
            <p>Drag 'n' drop some files here, or click to select files</p>
            <ul>
              {files.map(file => (
                <li key={file.path}>{file.path} - {file.size} bytes</li>
              ))}
            </ul>
          </div>
          {[0, 1, 2, 3].map(index => (
            <div key={index} className="mb-4">
              <select
                value={selectedPlayers[index] || ""}
                onChange={(e) => handlePlayerChange(index, e.target.value)}
                className="w-full p-2 border border-gray-300 rounded mb-2"
              >
                <option value="">Select Player</option>
                {users.map(user => (
                  <option key={user.id} value={user.id}>{user.firstname} {user.lastname}</option>
                ))}
              </select>
              <input
                type="number"
                placeholder="Enter score"
                value={playerScores[index]}
                onChange={(e) => handlePlayerScoreChange(index, e.target.value)}
                className="w-full p-2 border border-gray-300 rounded"
              />
            </div>
          ))}
          <button
            onClick={handleScoreSubmit}
            className="bg-gold text-black px-4 py-2 rounded"
          >
            Submit Score
          </button>
        </div>
      </main>
    </div>
  );
};

export default ScoresPage;
