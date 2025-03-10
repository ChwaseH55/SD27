import React, { useState } from "react";
import { useEffect } from "react";
import axios from "axios";
import { api } from '../config';  // Import our configured api instance

const EventsPage = () => {
  const [events, setEvents] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");

  // Fetch events from the API
  useEffect(() => {
    const fetchEvents = async () => {
      try {
        const response = await api.get(("/events"));  // Get all events
        setEvents(response.data);  // Populate the events state
      } catch (err) {
        console.error("Error fetching events:", err);
      }
    };

    fetchEvents();
  }, []); // Only fetch once on mount

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
                key={event.eventid}
                className="bg-white p-4 shadow rounded-lg border border-gray-200"
              >
                <h3 className="text-xl font-bold">{event.eventname}</h3>
                <p className="text-gray-500">{new Date(event.eventdate).toDateString()}</p>
                <p className="text-gray-700 mt-2">{event.eventdescription}</p>
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
