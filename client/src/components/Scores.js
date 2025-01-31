import React, { useState } from "react";

const ScoresPage = () => {
  const [scores, setScores] = useState([]);
  const [newScore, setNewScore] = useState("");

  const handleScoreSubmit = () => {
    if (!newScore.trim()) return;
    setScores([...scores, { id: scores.length + 1, score: newScore }]);
    setNewScore("");
    alert("Score submitted for approval!");
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
          <input
            type="number"
            placeholder="Enter your score"
            value={newScore}
            onChange={(e) => setNewScore(e.target.value)}
            className="w-full p-2 border border-gray-300 rounded mb-4"
          />
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
