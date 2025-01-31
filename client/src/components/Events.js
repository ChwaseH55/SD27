import React, { useState } from "react";

const EventsPage = () => {
  const [events, setEvents] = useState([
    {
      id: 1,
      title: "Spring Tournament",
      date: "2025-03-14",
      description: "A friendly competition to kick off the season.",
    },
    {
      id: 2,
      title: "Golf Workshop",
      date: "2025-02-20",
      description: "Learn tips and tricks from the pros.",
    },
  ]);

  return (
    <div className="bg-gray-100 min-h-screen">
      <header className="bg-black text-gold p-6 shadow-md">
        <h1 className="text-3xl font-bold text-center">Events</h1>
      </header>
      <main className="max-w-4xl mx-auto p-6">
        <div className="mb-6">
          <h2 className="text-2xl font-semibold">Upcoming Events</h2>
          <ul className="space-y-4 mt-4">
            {events.map((event) => (
              <li
                key={event.id}
                className="bg-white p-4 shadow rounded-lg border border-gray-200"
              >
                <h3 className="text-xl font-bold">{event.title}</h3>
                <p className="text-gray-500">{new Date(event.date).toDateString()}</p>
                <p className="text-gray-700 mt-2">{event.description}</p>
                <button
                  className="bg-gold text-black px-4 py-2 rounded mt-4"
                  onClick={() => alert("Add to calendar functionality")}
                >
                  Add to Calendar
                </button>
              </li>
            ))}
          </ul>
        </div>
      </main>
    </div>
  );
};

export default EventsPage;
