import React, { useState, useEffect } from "react";
import { api } from '../config';  // Import our configured api instance
import { useSelector } from 'react-redux'; // Import useSelector to access Redux state

const AdminDashboard = () => {
  // Get the current user from Redux store
  const currentUser = useSelector(state => state.user.user);
  const userId = currentUser ? currentUser.id : 1; // Use the current user's ID or default to 1

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
    created_by_user_id: userId, // Use the current user's ID
    event_description: "",
  });
  const [announcement, setAnnouncement] = useState({
    title: "",
    content: "",
    userid: userId // Use the current user's ID
  });
  const [isCreatingAnnouncement, setIsCreatingAnnouncement] = useState(false);

  // Update event and announcement user IDs when the current user changes
  useEffect(() => {
    setNewEvent(prev => ({ ...prev, created_by_user_id: userId }));
    setAnnouncement(prev => ({ ...prev, userid: userId }));
  }, [userId]);

  // Fetch forum posts, users, events, and score submissions from API
  useEffect(() => {
    const fetchData = async () => {
      try {
        const [forumResponse, usersResponse, eventsResponse] = await Promise.all([
          api.get("/forum/posts"),
          api.get("/users"),
          api.get("/events"),
          //api.get("/scores"),
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
      const response = await api.post("/events", newEvent);
      setEvents([...events, response.data]);
      setNewEvent({
        event_name: "",
        event_date: "",
        event_location: "",
        event_type: "",
        requires_registration: false,
        created_by_user_id: userId, // Use the current user's ID
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
      const response = await api.put(`/events/${isEditingEvent}`, newEvent);
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
      await api.delete(`/events/${eventId}`);
      setEvents(events.filter(event => event.eventid !== eventId));
    } catch (error) {
      console.error("Error deleting event:", error);
    }
  };

  // Handle deleting a forum post
  const handleDeletePost = async (postId) => {
    try {
      await api.delete(`/forum/posts/${postId}`);
      setForumPosts((prevPosts) => prevPosts.filter((post) => post.postid !== postId));
      alert("Post deleted successfully!");
    } catch (error) {
      console.error("Error deleting post:", error);
      alert("Failed to delete the post. Please try again.");
    }
  };

  // Toggle to show the announcement creation form
  const handleCreateAnnouncementClick = () => {
    setIsCreatingAnnouncement(true);
  };

  // Create an announcement
  const handleCreateAnnouncement = async (e) => {
    e.preventDefault();
    try {
      const response = await api.post('/announcements', announcement);
      alert('Announcement created successfully!');
      setAnnouncement({
        title: "",
        content: "",
        userid: userId // Use the current user's ID
      });
      setIsCreatingAnnouncement(false);
    } catch (error) {
      console.error("Error creating announcement:", error);
    }
  };

  // Update user role
  const handleUpdateUserRole = async (userId, newRoleId) => {
    try {
      // Use the general user update endpoint with the roleid field
      const response = await api.put(`/users/${userId}`, { roleid: newRoleId });
      setUsers(users.map(user => user.id === userId ? { ...user, roleid: newRoleId } : user));
      alert('User role updated successfully!');
    } catch (error) {
      console.error("Error updating user role:", error);
    }
  };

  return (
    <div className="bg-gray-100 min-h-screen">
      <header className="bg-black text-gold p-6 shadow-md">
        <h1 className="text-3xl font-bold text-center">Admin Dashboard</h1>
      </header>
      <main className="max-w-4xl mx-auto p-6">
        {/* Announcement Section */}
        <button
          onClick={handleCreateAnnouncementClick}
          className="w-full bg-blue-500 text-white p-2 rounded mb-4"
        >
          Create Announcement
        </button>
        {isCreatingAnnouncement && (
          <form onSubmit={handleCreateAnnouncement} className="bg-white p-4 shadow rounded-lg border border-gray-200 mt-6">
            <h3 className="text-xl font-semibold">Create Announcement</h3>
            <input
              type="text"
              value={announcement.title}
              onChange={(e) => setAnnouncement({...announcement, title: e.target.value})}
              placeholder="Enter announcement title"
              className="w-full p-2 my-2 border border-gray-300 rounded"
              required
            />
            <textarea
              value={announcement.content}
              onChange={(e) => setAnnouncement({...announcement, content: e.target.value})}
              placeholder="Enter announcement content"
              className="w-full p-2 my-2 border border-gray-300 rounded"
              required
            />
            <div className="flex justify-end space-x-4">
              <button
                type="button"
                onClick={() => {
                  setIsCreatingAnnouncement(false);
                  setAnnouncement({
                    title: "",
                    content: "",
                    userid: userId
                  });
                }}
                className="text-gray-500"
              >
                Cancel
              </button>
              <button type="submit" className="bg-blue-500 text-white p-2 rounded">
                Create
              </button>
            </div>
          </form>
        )}

        {/* User Management Section */}
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
                  <select
                    value={user.roleid || 1}
                    onChange={(e) => handleUpdateUserRole(user.id, parseInt(e.target.value))}
                    className="w-full p-2 my-2 border border-gray-300 rounded"
                  >
                    <option value={1}>Guest</option>
                    <option value={2}>Member (Dues Not Paid)</option>
                    <option value={3}>Member (Dues Paid)</option>
                    <option value={4}>Coach</option>
                    <option value={5}>Executive Board</option>
                    <option value={6}>President</option>
                  </select>
                </li>
              ))}
            </ul>
          </div>
        )}

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
                    created_by_user_id: userId, // Use the current user's ID
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
