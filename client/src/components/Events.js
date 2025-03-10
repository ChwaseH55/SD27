import React, { useState } from "react";
import { useEffect } from "react";
import axios from "axios";
import { useSelector } from "react-redux";
import { api } from '../config';  // Import our configured api instance

const EventsPage = () => {
  const [events, setEvents] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [myEvents, setMyEvents] = useState([]);
  const [filter, setFilter] = useState("all");
  const [registrations, setRegistrations] = useState({});

  const user = useSelector((state) => state.user.user);

  //fetch all events
  const fetchEvents = async () => {
    try {
      const response = await axios.get("/api/events");
      setEvents(response.data);
    } catch (err) {
      console.error("Error fetching events:", err);
    }
  };

  // Fetch user's registered events
  const fetchMyEvents = async () => {
    try {
      const response = await axios.get(`/api/events/my-events/${user.id}`);
      setMyEvents(response.data);
      const registeredEventIds = response.data.reduce((acc, event) => {
        acc[event.eventid] = true;
        return acc;
      }, {});
      setRegistrations(registeredEventIds);
    } catch (err) {
      console.error("Error fetching user events:", err);
    }
  }

  // Fetch events from the API
  useEffect(() => {
    fetchEvents();

    if (user) {
      fetchMyEvents();
    }
  }, [user], fetchMyEvents, fetchEvents); // Only fetch once on mount


  // Register or unregister user from an event
  const toggleRegistration = async (eventid) => {
    console.log(eventid, user.id)
    try {
      console.log(registrations[eventid])
      if (registrations[eventid]) {
        console.log(eventid, user.id)
        await axios.delete(`/api/events/unregister/${eventid}/${user.id}`);

        // Optimistically update state
        setRegistrations((prev) => {
          const updated = { ...prev };
          delete updated[eventid];
          return updated;
        });

        // Remove event from myEvents list
        setMyEvents((prev) => prev.filter(event => event.eventid !== eventid));

      } else {
        await axios.post("/api/events/register", { eventid, userid: user.id });

        // Optimistically update state
        setRegistrations((prev) => ({ ...prev, [eventid]: true }));
        
        // Find the event details and add it to myEvents
        const registeredEvent = events.find(event => event.eventid === eventid);
        if (registeredEvent) {
          setMyEvents((prev) => [...prev, registeredEvent]);
        }
      }
    } catch (err) {
      console.error("Error toggling registration:", err);
    }
  };

  // Filter events based on selection
  const displayedEvents = filter === "all" ? events : myEvents;

  return (
    <div className="bg-gray-100 min-h-screen">
      <header className="bg-black text-gold p-6 shadow-md">
        <h1 className="text-3xl font-bold text-center">Events</h1>
      </header>
      <main className="max-w-4xl mx-auto p-6">
        <div>
          <button
            className={`px-4 py-2 rounded ${filter === "all" ? "bg-gray-300" : "bg-gold text-black"
              }`}
            onClick={() => setFilter("all")}
          >
            All Events
          </button>
          <button
            className={`ml-2 px-4 py-2 rounded ${filter === "my" ? "bg-gray-300" : "bg-gold text-black"
              }`}
            onClick={() => setFilter("my")}
          >
            My Events
          </button>
        </div>
        <ul className="space-y-4">
          {displayedEvents.map((event) => (
            <li
              key={event.eventid}
              className="bg-white p-4 shadow rounded-lg border border-gray-200"
            >
              <h3 className="text-xl font-bold">{event.eventname}</h3>
              <p className="text-gray-500">
                {new Date(event.eventdate).toDateString()}
              </p>
              <p className="text-gray-700 mt-2">{event.eventdescription}</p>
              <button
                className={`px-4 py-2 rounded mt-4 ${registrations[event.eventid]
                  ? "bg-red-500 text-white"
                  : "bg-gold text-black"
                  }`}
                onClick={() => toggleRegistration(event.eventid)}
              >
                {registrations[event.eventid] ? "Unregister" : "Register"}
              </button>
            </li>
          ))}
        </ul>
      </main>
    </div>
  );
};

export default EventsPage;
