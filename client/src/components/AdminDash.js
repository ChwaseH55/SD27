import React, { useState, useEffect } from "react";
import axios from "axios";

const AdminDashboard = () => {
  const [forumPosts, setForumPosts] = useState([]);
  const [users, setUsers] = useState([]);
  const [events, setEvents] = useState([]);
  //const [scoreSubmissions, setScoreSubmissions] = useState([]);
  const [isForumPostsVisible, setIsForumPostsVisible] = useState(false);
  const [isUsersVisible, setIsUsersVisible] = useState(false);
  const [isEventsVisible, setIsEventsVisible] = useState(false);
  const [isCreatingEvent, setIsCreatingEvent] = useState(false);
  const [isEditingEvent, setIsEditingEvent] = useState(null);
  const [newEvent, setNewEvent] = useState({
    event_name: "",
    event_date: "",
    event_location: "",
    event_type: "",
    requires_registration: false,
    event_description: "",
  });

  // Fetch forum posts, users, events, and score submissions from API
  useEffect(() => {
    const fetchData = async () => {
      try {
        const [forumResponse, usersResponse, eventsResponse] = await Promise.all([
          axios.get("/api/forum/posts"),
          axios.get("/api/users"),
          axios.get("/api/events"),
          //axios.get("/api/scores"),
        ]);

        setForumPosts(forumResponse.data);
        setUsers(usersResponse.data);
        setEvents(eventsResponse.data);
        //setScoreSubmissions(scoreSubmissionsResponse.data);
      } catch (error) {
        console.error("Error fetching data:", error);
      }
    };

    fetchData();
  }, []);

  // Handle event form changes
  const handleEventChange = (e) => {
    setNewEvent({
      ...newEvent,
      [e.target.name]: e.target.value,
    });
  };

  // Create a new event
  const handleCreateEvent = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post("/api/events", newEvent);
      setEvents([...events, response.data]);
      setNewEvent({
        event_name: "",
        event_date: "",
        event_location: "",
        event_type: "",
        requires_registration: false,
        event_description: "",
      });
      setIsCreatingEvent(false);
    } catch (error) {
      console.error("Error creating event:", error);
    }
  };

    // Toggle to show the event creation form
    const handleCreateEventClick = () => {
      setIsCreatingEvent(true);
      setIsEditingEvent(null); // Clear editing state if switching to create
    };

  // Update an existing event
  const handleUpdateEvent = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.put(`/api/events/${isEditingEvent}`, newEvent);
      setEvents(events.map(event => event.eventid === response.data.eventid ? response.data : event));
      setIsEditingEvent(null);
      setNewEvent({
        event_name: "",
        event_date: "",
        event_location: "",
        event_type: "",
        requires_registration: false,
        event_description: "",
      });
    } catch (error) {
      console.error("Error updating event:", error);
    }
  };

  // Handle event deletion
  const handleDeleteEvent = async (eventId) => {
    try {
      await axios.delete(`/api/events/${eventId}`);
      setEvents(events.filter(event => event.eventid !== eventId));
    } catch (error) {
      console.error("Error deleting event:", error);
    }
  };

  // Handle deleting a forum post
  const handleDeletePost = async (postId) => {
    try {
      const response = await axios.delete(`/api/forum/posts/${postId}`);
      setForumPosts((prevPosts) => prevPosts.filter((post) => post.postid !== postId));
      alert("Post deleted successfully!");
    } catch (error) {
      console.error("Error deleting post:", error);
      alert("Failed to delete the post. Please try again.");
    }
  };

  return (
    <div className="bg-gray-100 min-h-screen">
      <header className="bg-black text-gold p-6 shadow-md">
        <h1 className="text-3xl font-bold text-center">Admin Dashboard</h1>
      </header>
      <main className="max-w-4xl mx-auto p-6">
        {/* Button to Create Event */}
        <button
          onClick={() => setIsCreatingEvent(true)}
          className="w-full bg-blue-500 text-white p-2 rounded mb-4"
        >
          Create Event
        </button>
  
        {/* Forum Posts Section */}
        <button
          className="w-full bg-gray-300 p-2 rounded mb-2"
          onClick={() => setIsForumPostsVisible(!isForumPostsVisible)}
        >
          {isForumPostsVisible ? "Hide Forum Posts" : "Show Forum Posts"}
        </button>
        {isForumPostsVisible && (
          <div className="bg-white p-4 shadow rounded-lg border border-gray-200">
            <h3 className="text-xl font-semibold">Forum Posts</h3>
            <ul className="space-y-4">
              {forumPosts.map((post) => (
                <li key={post.postid} className="bg-white p-4 shadow rounded-lg border border-gray-200">
                  <h4 className="text-lg font-bold">{post.title}</h4>
                  <p>{post.content}</p>
                  <small className="text-gray-600">
                    Posted by {post.userid} on {new Date(post.createddate).toLocaleDateString()}
                  </small>
                  <div className="mt-2 flex justify-end space-x-4">
                    <button onClick={() => handleDeletePost(post.postid)} className="text-red-500 underline">
                      Delete
                    </button>
                  </div>
                </li>
              ))}
            </ul>
          </div>
        )}
  
        {/* Users Section */}
        <button
          className="w-full bg-gray-300 p-2 rounded mb-2"
          onClick={() => setIsUsersVisible(!isUsersVisible)}
        >
          {isUsersVisible ? "Hide Users" : "Show Users"}
        </button>
        {isUsersVisible && (
          <div className="bg-white p-4 shadow rounded-lg border border-gray-200">
            <h3 className="text-xl font-semibold">Users</h3>
            <ul className="space-y-4">
              {users.map((user) => (
                <li key={user.id} className="bg-white p-4 shadow rounded-lg border border-gray-200">
                  <h4 className="text-lg font-bold">{user.username}</h4>
                  <p>{user.email}</p>
                </li>
              ))}
            </ul>
          </div>
        )}
  
        {/* Events Section */}
        <button
          className="w-full bg-gray-300 p-2 rounded mb-2"
          onClick={() => setIsEventsVisible(!isEventsVisible)}
        >
          {isEventsVisible ? "Hide Events" : "Show Events"}
        </button>
        {isEventsVisible && (
          <div className="bg-white p-4 shadow rounded-lg border border-gray-200">
            <h3 className="text-xl font-semibold">Events</h3>
            <ul className="space-y-4">
              {events.map((event) => (
                <li key={event.eventid} className="bg-white p-4 shadow rounded-lg border border-gray-200">
                  <h4 className="text-lg font-bold">{event.eventname}</h4>
                  <p>{event.eventdescription}</p>
                  <small className="text-gray-600">
                    {new Date(event.eventdate).toLocaleDateString()} at {event.eventlocation}
                  </small>
                  <div className="mt-2 flex justify-end space-x-4">
                    <button
                      onClick={() => {
                        setIsEditingEvent(event.eventid);
                        setNewEvent({
                          event_name: event.eventname,
                          event_date: event.eventdate,
                          event_location: event.eventlocation,
                          event_type: event.eventtype,
                          requires_registration: event.requiresregistration,
                          event_description: event.eventdescription,
                        });
                      }}
                      className="text-blue-500 underline"
                    >
                      Edit
                    </button>
                    <button
                      onClick={() => handleDeleteEvent(event.eventid)}
                      className="text-red-500 underline"
                    >
                      Delete
                    </button>
                  </div>
                </li>
              ))}
            </ul>
          </div>
        )}
  
        {/* Event Form (Create or Edit Event) */}
        {(isCreatingEvent || isEditingEvent) && (
          <form onSubmit={isEditingEvent ? handleUpdateEvent : handleCreateEvent} className="bg-white p-4 shadow rounded-lg border border-gray-200 mt-6">
            <h3 className="text-xl font-semibold">{isEditingEvent ? "Edit Event" : "Create Event"}</h3>
            <input
              type="text"
              name="event_name"
              value={newEvent.event_name}
              onChange={handleEventChange}
              placeholder="Event Name"
              className="w-full p-2 my-2 border border-gray-300 rounded"
            />
            <input
              type="datetime-local"
              name="event_date"
              value={newEvent.event_date}
              onChange={handleEventChange}
              className="w-full p-2 my-2 border border-gray-300 rounded"
            />
            <input
              type="text"
              name="event_location"
              value={newEvent.event_location}
              onChange={handleEventChange}
              placeholder="Event Location"
              className="w-full p-2 my-2 border border-gray-300 rounded"
            />
            <textarea
              name="event_description"
              value={newEvent.event_description}
              onChange={handleEventChange}
              placeholder="Event Description"
              className="w-full p-2 my-2 border border-gray-300 rounded"
            />
            <div className="flex justify-end space-x-4">
              <button
                type="button"
                onClick={() => {
                  setIsCreatingEvent(false);
                  setIsEditingEvent(null);
                  setNewEvent({
                    event_name: "",
                    event_date: "",
                    event_location: "",
                    event_type: "",
                    requires_registration: false,
                    event_description: "",
                  });
                }}
                className="text-gray-500"
              >
                Cancel
              </button>
              <button type="submit" className="bg-blue-500 text-white p-2 rounded">
                {isEditingEvent ? "Update" : "Create"}
              </button>
            </div>
          </form>
        )}
      </main>
    </div>
  );
}

export default AdminDashboard;
