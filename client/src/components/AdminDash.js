import React, { useState } from "react";

const AdminDashboard = () => {
  const [users, setUsers] = useState([
    { id: 1, name: "User1", email: "user1@example.com", profileImage: "default.jpg" },
    { id: 2, name: "User2", email: "user2@example.com", profileImage: "default.jpg" },
  ]);
  const [scoreRequests, setScoreRequests] = useState([
    { id: 1, user: "User1", score: 72 },
    { id: 2, user: "User2", score: 75 },
  ]);
  const [selectedUser, setSelectedUser] = useState(null);

  const handleApproveScore = (requestId) => {
    setScoreRequests(scoreRequests.filter((req) => req.id !== requestId));
    alert("Score approved!");
  };

  const handleEditUser = (userId) => {
    const user = users.find((u) => u.id === userId);
    setSelectedUser(user);
  };

  const handleSaveUserChanges = () => {
    alert("User information updated!");
    setSelectedUser(null);
  };

  return (
    <div className="bg-gray-100 min-h-screen">
      <header className="bg-black text-gold p-6 shadow-md">
        <h1 className="text-3xl font-bold text-center">Admin Dashboard</h1>
      </header>
      <main className="max-w-4xl mx-auto p-6">
        <div className="mb-6">
          <h2 className="text-2xl font-semibold">Score Requests</h2>
          <ul className="space-y-4 mt-4">
            {scoreRequests.map((req) => (
              <li
                key={req.id}
                className="bg-white p-4 shadow rounded-lg border border-gray-200"
              >
                <p>
                  {req.user} submitted a score of {req.score}.
                </p>
                <button
                  onClick={() => handleApproveScore(req.id)}
                  className="bg-gold text-black px-4 py-2 rounded mt-2"
                >
                  Approve
                </button>
              </li>
            ))}
          </ul>
        </div>

        <div className="bg-white p-6 shadow rounded-lg border border-gray-200 mb-6">
          <h2 className="text-2xl font-semibold mb-4">Search and Edit Members</h2>
          <ul className="space-y-4">
            {users.map((user) => (
              <li key={user.id} className="flex justify-between items-center">
                <span>{user.name} ({user.email})</span>
                <button
                  onClick={() => handleEditUser(user.id)}
                  className="text-blue-500 underline"
                >
                  Edit
                </button>
              </li>
            ))}
          </ul>
        </div>

        {selectedUser && (
          <div className="bg-white p-6 shadow rounded-lg border border-gray-200">
            <h2 className="text-xl font-bold">Edit User: {selectedUser.name}</h2>
            <input
              type="text"
              placeholder="Name"
              defaultValue={selectedUser.name}
              className="w-full p-2 border border-gray-300 rounded mb-4"
            />
            <input
              type="email"
              placeholder="Email"
              defaultValue={selectedUser.email}
              className="w-full p-2 border border-gray-300 rounded mb-4"
            />
            <button
              onClick={handleSaveUserChanges}
              className="bg-gold text-black px-4 py-2 rounded"
            >
              Save Changes
            </button>
          </div>
        )}
      </main>
    </div>
  );
};

export default AdminDashboard;
