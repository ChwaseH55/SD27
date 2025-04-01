import React, { useState, useEffect } from 'react';
import { Calendar, dateFnsLocalizer, Views } from 'react-big-calendar';
import 'react-big-calendar/lib/css/react-big-calendar.css';
import { format, parse, startOfWeek, getDay, addHours } from 'date-fns';
import enUS from 'date-fns/locale/en-US';
import Nav from './Nav';
import { api } from '../config';
import { useSelector } from 'react-redux';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import './CalendarStyles.css'; // We'll create this file next

const locales = {
    'en-US': enUS,
};

const localizer = dateFnsLocalizer({
    format,
    parse,
    startOfWeek,
    getDay,
    locales,
});

const CalendarPage = () => {
    const location = useLocation();
    const navigate = useNavigate();
    const [userEvents, setUserEvents] = useState([]);
    const [allEvents, setAllEvents] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [viewType, setViewType] = useState('calendar');
    const [calendarView, setCalendarView] = useState(Views.MONTH);
    const [selectedEvent, setSelectedEvent] = useState(null);
    const [registering, setRegistering] = useState(false);
    const [registrations, setRegistrations] = useState({});
    const [eventsFilter, setEventsFilter] = useState('all');
    
    const user = useSelector(state => state.user.user);

    // Parse URL query parameters to set the initial view
    useEffect(() => {
        const queryParams = new URLSearchParams(location.search);
        const viewParam = queryParams.get('view');
        if (viewParam === 'events') {
            setViewType('events');
        }
    }, [location.search]);
    
    // Update URL when view type changes
    const handleViewTypeChange = (newViewType) => {
        setViewType(newViewType);
        if (newViewType === 'events') {
            navigate('/calendar?view=events');
        } else {
            navigate('/calendar');
        }
    };

    // Fetch all events
    useEffect(() => {
        const fetchEvents = async () => {
            setLoading(true);
            try {
                const allEventsResponse = await api.get('/events');
                setAllEvents(allEventsResponse.data);
                
                if (user && user.id) {
                    const myEventsResponse = await api.get(`/events/my-events/${user.id}`);
                    
                    // Create a map of registered event IDs
                    const registeredEventIds = myEventsResponse.data.reduce((acc, event) => {
                        acc[event.eventid] = true;
                        return acc;
                    }, {});
                    setRegistrations(registeredEventIds);
                    
                    // Format events for the Calendar component
                    const formattedEvents = allEventsResponse.data.map(event => {
                        const startDate = new Date(event.eventdate);
                        return {
                            id: event.eventid,
                            title: event.eventname,
                            start: startDate,
                            end: addHours(startDate, 2), // Add 2 hours as default duration
                            allDay: false,
                            resource: {
                                id: event.eventid,
                                location: event.eventlocation,
                                description: event.eventdescription,
                                type: event.eventtype,
                                isRegistered: registeredEventIds[event.eventid] || false
                            }
                        };
                    });
                    
                    setUserEvents(formattedEvents);
                }
                setLoading(false);
            } catch (error) {
                console.error("Error fetching events:", error);
                setError("Failed to load events. Please try again.");
                setLoading(false);
            }
        };

        fetchEvents();
    }, [user]);

    // Custom event component to show more details
    const EventComponent = ({ event }) => (
        <div className={`rbc-event-content ${event.resource?.isRegistered ? 'registered-event' : ''}`}>
            <strong>{event.title}</strong>
            {event.resource?.location && (
                <div className="event-location">
                    <small>{event.resource.location}</small>
                </div>
            )}
        </div>
    );

    // Handle event click
    const handleSelectEvent = (event) => {
        setSelectedEvent(event);
    };

    // Toggle registration for an event
    const toggleRegistration = async (eventId) => {
        if (!user || !user.id) return;
        
        setRegistering(true);
        try {
            if (registrations[eventId]) {
                await api.delete(`/events/unregister/${eventId}/${user.id}`);
                
                // Update registrations state
                setRegistrations(prev => {
                    const updated = { ...prev };
                    delete updated[eventId];
                    return updated;
                });
            } else {
                await api.post("/events/register", { eventid: eventId, userid: user.id });
                
                // Update registrations state
                setRegistrations(prev => ({ ...prev, [eventId]: true }));
            }
            
            // Update event display
            setUserEvents(prevEvents => 
                prevEvents.map(event => {
                    if (event.id === eventId) {
                        return {
                            ...event,
                            resource: {
                                ...event.resource,
                                isRegistered: !registrations[eventId]
                            }
                        };
                    }
                    return event;
                })
            );
            
        } catch (error) {
            console.error("Error toggling registration:", error);
        } finally {
            setRegistering(false);
        }
    };

    // Close event details modal
    const closeEventDetails = () => {
        setSelectedEvent(null);
    };

    // Format date for display
    const formatEventDate = (dateString) => {
        const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' };
        return new Date(dateString).toLocaleDateString(undefined, options);
    };

    // Render loading spinner
    if (loading) {
        return (
            <div className="flex flex-col min-h-screen bg-gray-50">
                <Nav isLoggedIn={!!user} />
                <div className="flex-grow flex items-center justify-center">
                    <div className="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-yellow-500"></div>
                </div>
            </div>
        );
    }

    // Render error message
    if (error) {
        return (
            <div className="flex flex-col min-h-screen bg-gray-50">
                <Nav isLoggedIn={!!user} />
                <div className="flex-grow flex flex-col items-center justify-center text-red-500">
                    <p className="text-xl">{error}</p>
                    <button 
                        className="mt-4 px-4 py-2 bg-yellow-500 text-white rounded-md hover:bg-yellow-600 transition"
                        onClick={() => window.location.reload()}
                    >
                        Try Again
                    </button>
                </div>
            </div>
        );
    }

    return (
        <div className="flex flex-col min-h-screen bg-gray-50" 
             style={{
                backgroundImage: "linear-gradient(to bottom, rgba(250, 244, 230, 0.8), rgba(243, 244, 246, 0.9) 70%, rgba(209, 213, 219, 1))",
            }}>
            {/* Navbar */}
            <Nav isLoggedIn={!!user} />

            {/* Header Section */}
            <header className="relative pt-24 pb-16 px-4 sm:px-6 lg:px-8 bg-gradient-to-r from-yellow-500 to-yellow-600 text-white overflow-hidden">
                <div className="absolute inset-0 opacity-20" style={{
                    backgroundImage: "radial-gradient(white 2px, transparent 0)",
                    backgroundSize: "30px 30px",
                    backgroundPosition: "0 0",
                }}></div>
                <div className="max-w-7xl mx-auto">
                    <div className="text-center">
                        <h1 className="text-4xl md:text-5xl font-bold">Club Calendar</h1>
                        <p className="mt-3 text-lg md:text-xl text-yellow-100 max-w-3xl mx-auto">
                            Stay updated with upcoming tournaments, practice sessions, and social events.
                        </p>
                    </div>
                </div>
                {/* Wave SVG divider */}
                <div className="absolute bottom-0 left-0 right-0 overflow-hidden">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 120" preserveAspectRatio="none" className="fill-current text-gray-50" style={{ width: '100%', height: '50px' }}>
                        <path d="M321.39,56.44c58-10.79,114.16-30.13,172-41.86,82.39-16.72,168.19-17.73,250.45-.39C823.78,31,906.67,72,985.66,92.83c70.05,18.48,146.53,26.09,214.34,3V0H0V27.35A600.21,600.21,0,0,0,321.39,56.44Z"></path>
                    </svg>
                </div>
            </header>

            {/* Calendar/List View Tabs */}
            <div className="max-w-7xl mx-auto w-full px-4 sm:px-6 lg:px-8 mt-8 mb-16">
                <div className="bg-white shadow-md rounded-lg overflow-hidden">
                    <div className="border-b border-gray-200">
                        <nav className="-mb-px flex">
                            <button
                                onClick={() => handleViewTypeChange('calendar')}
                                className={`${viewType === 'calendar' 
                                    ? 'border-yellow-500 text-yellow-600' 
                                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                                } whitespace-nowrap py-4 px-6 border-b-2 font-medium text-sm`}
                            >
                                Calendar View
                            </button>
                            <button
                                onClick={() => handleViewTypeChange('events')}
                                className={`${viewType === 'events' 
                                    ? 'border-yellow-500 text-yellow-600' 
                                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                                } whitespace-nowrap py-4 px-6 border-b-2 font-medium text-sm`}
                            >
                                Events
                            </button>
                        </nav>
                    </div>

                    {/* Calendar View Options */}
                    {viewType === 'calendar' && (
                        <div className="p-4 bg-gray-50 border-b">
                            <div className="flex flex-wrap items-center justify-between">
                                <div className="flex space-x-2">
                                    <button 
                                        onClick={() => setCalendarView(Views.MONTH)}
                                        className={`px-3 py-1 rounded-md text-sm ${calendarView === Views.MONTH ? 'bg-yellow-500 text-white' : 'bg-white text-gray-700 border border-gray-300'}`}
                                    >
                                        Month
                                    </button>
                                    <button 
                                        onClick={() => setCalendarView(Views.WEEK)}
                                        className={`px-3 py-1 rounded-md text-sm ${calendarView === Views.WEEK ? 'bg-yellow-500 text-white' : 'bg-white text-gray-700 border border-gray-300'}`}
                                    >
                                        Week
                                    </button>
                                    <button 
                                        onClick={() => setCalendarView(Views.DAY)}
                                        className={`px-3 py-1 rounded-md text-sm ${calendarView === Views.DAY ? 'bg-yellow-500 text-white' : 'bg-white text-gray-700 border border-gray-300'}`}
                                    >
                                        Day
                                    </button>
                                    <button 
                                        onClick={() => setCalendarView(Views.AGENDA)}
                                        className={`px-3 py-1 rounded-md text-sm ${calendarView === Views.AGENDA ? 'bg-yellow-500 text-white' : 'bg-white text-gray-700 border border-gray-300'}`}
                                    >
                                        Agenda
                                    </button>
                                </div>
                                <p className="text-sm text-gray-600 mt-2 sm:mt-0">
                                    <span className="inline-block w-3 h-3 bg-yellow-500 rounded-full mr-1"></span> Registered Events
                                </p>
                            </div>
                        </div>
                    )}

                    {/* Calendar View */}
                    {viewType === 'calendar' && (
                        <div className="calendar-container p-4">
                            <Calendar
                                localizer={localizer}
                                events={userEvents}
                                startAccessor="start"
                                endAccessor="end"
                                style={{ height: 600 }}
                                views={[Views.MONTH, Views.WEEK, Views.DAY, Views.AGENDA]}
                                view={calendarView}
                                onView={setCalendarView}
                                components={{
                                    event: EventComponent
                                }}
                                onSelectEvent={handleSelectEvent}
                                eventPropGetter={(event) => ({
                                    className: event.resource?.isRegistered ? 'registered-event' : '',
                                })}
                            />
                        </div>
                    )}

                    {/* List View (now Events) */}
                    {viewType === 'events' && (
                        <div className="p-4">
                            <div className="mb-4 flex space-x-2">
                                <button
                                    onClick={() => setEventsFilter('all')}
                                    className={`px-4 py-2 rounded-md text-sm ${eventsFilter === 'all' 
                                        ? 'bg-yellow-500 text-white' 
                                        : 'bg-white text-gray-700 border border-gray-300 hover:bg-gray-50'}`}
                                >
                                    All Events
                                </button>
                                <button
                                    onClick={() => setEventsFilter('my')}
                                    className={`px-4 py-2 rounded-md text-sm ${eventsFilter === 'my' 
                                        ? 'bg-yellow-500 text-white' 
                                        : 'bg-white text-gray-700 border border-gray-300 hover:bg-gray-50'}`}
                                >
                                    My Events
                                </button>
                            </div>
                            <div className="space-y-4">
                                {allEvents.length === 0 ? (
                                    <div className="text-center py-10">
                                        <svg className="w-16 h-16 text-gray-400 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                        </svg>
                                        <p className="mt-4 text-gray-500 text-lg">No events scheduled at this time.</p>
                                    </div>
                                ) : (
                                    (eventsFilter === 'all' ? allEvents : allEvents.filter(event => registrations[event.eventid])).map(event => (
                                        <div key={event.eventid} 
                                            className={`bg-white rounded-lg shadow-md overflow-hidden border-l-4 
                                                ${registrations[event.eventid] ? 'border-yellow-500' : 'border-gray-300'} 
                                                transition-all duration-200 hover:shadow-lg`}
                                            onClick={() => {
                                                const formattedEvent = {
                                                    id: event.eventid,
                                                    title: event.eventname,
                                                    start: new Date(event.eventdate),
                                                    resource: {
                                                        id: event.eventid,
                                                        location: event.eventlocation,
                                                        description: event.eventdescription,
                                                        type: event.eventtype,
                                                        isRegistered: registrations[event.eventid] || false
                                                    }
                                                };
                                                setSelectedEvent(formattedEvent);
                                            }}
                                        >
                                            <div className="p-5">
                                                <div className="flex flex-wrap justify-between items-start">
                                                    <div>
                                                        <h3 className="text-xl font-bold text-gray-800">{event.eventname}</h3>
                                                        <p className="text-sm text-gray-500 mt-1 flex items-center">
                                                            <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                                            </svg>
                                                            {new Date(event.eventdate).toLocaleDateString(undefined, { 
                                                                weekday: 'long', 
                                                                year: 'numeric', 
                                                                month: 'long', 
                                                                day: 'numeric',
                                                                hour: '2-digit',
                                                                minute: '2-digit'
                                                            })}
                                                        </p>
                                                        {event.eventlocation && (
                                                            <p className="text-sm text-gray-500 mt-1 flex items-center">
                                                                <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                                                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                                                </svg>
                                                                {event.eventlocation}
                                                            </p>
                                                        )}
                                                    </div>
                                                    <div className="mt-2 sm:mt-0">
                                                        <button
                                                            onClick={(e) => {
                                                                e.stopPropagation(); // Prevent card click event
                                                                toggleRegistration(event.eventid);
                                                            }}
                                                            disabled={registering}
                                                            className={`px-4 py-2 rounded-md text-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yellow-500
                                                                ${registrations[event.eventid] 
                                                                    ? 'bg-red-100 text-red-700 hover:bg-red-200' 
                                                                    : 'bg-yellow-500 text-white hover:bg-yellow-600'
                                                                }
                                                                ${registering ? 'opacity-75 cursor-not-allowed' : ''}
                                                            `}
                                                        >
                                                            {registering ? (
                                                                <span className="flex items-center">
                                                                    <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                                                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                                                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                                                    </svg>
                                                                    Processing...
                                                                </span>
                                                            ) : registrations[event.eventid] ? 'Unregister' : 'Register'}
                                                        </button>
                                                    </div>
                                                </div>
                                                {event.eventdescription && (
                                                    <div className="mt-4">
                                                        <div className="text-sm text-gray-700">{event.eventdescription}</div>
                                                    </div>
                                                )}
                                                {event.eventtype && (
                                                    <div className="mt-3">
                                                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                                                            {event.eventtype}
                                                        </span>
                                                    </div>
                                                )}
                                            </div>
                                        </div>
                                    ))
                                )}
                            </div>
                        </div>
                    )}
                </div>
            </div>

            {/* Event Details Modal */}
            {selectedEvent && (
                <div className="fixed inset-0 bg-gray-800 bg-opacity-75 flex items-center justify-center z-50 px-4">
                    <div className="bg-white rounded-lg max-w-md w-full overflow-hidden">
                        <div className="bg-yellow-500 px-6 py-4">
                            <div className="flex justify-between items-center">
                                <h3 className="text-xl font-bold text-white">{selectedEvent.title}</h3>
                                <button 
                                    onClick={closeEventDetails}
                                    className="text-white hover:text-yellow-200 focus:outline-none"
                                >
                                    <svg className="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12"></path>
                                    </svg>
                                </button>
                            </div>
                        </div>
                        <div className="px-6 py-4">
                            <p className="text-sm text-gray-600 flex items-center mb-3">
                                <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                </svg>
                                {formatEventDate(selectedEvent.start)}
                            </p>
                            {selectedEvent.resource?.location && (
                                <p className="text-sm text-gray-600 flex items-center mb-3">
                                    <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                    </svg>
                                    {selectedEvent.resource.location}
                                </p>
                            )}
                            {selectedEvent.resource?.type && (
                                <p className="text-sm text-gray-600 flex items-center mb-3">
                                    <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"></path>
                                    </svg>
                                    {selectedEvent.resource.type}
                                </p>
                            )}
                            {selectedEvent.resource?.description && (
                                <div className="mt-4">
                                    <h4 className="font-medium text-gray-800 mb-2">Description</h4>
                                    <p className="text-gray-600">{selectedEvent.resource.description}</p>
                                </div>
                            )}
                        </div>
                        <div className="bg-gray-50 px-6 py-4">
                            <button
                                onClick={() => toggleRegistration(selectedEvent.id)}
                                disabled={registering}
                                className={`w-full px-4 py-2 rounded-md text-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yellow-500
                                    ${selectedEvent.resource?.isRegistered 
                                        ? 'bg-red-100 text-red-700 hover:bg-red-200' 
                                        : 'bg-yellow-500 text-white hover:bg-yellow-600'
                                    }
                                    ${registering ? 'opacity-75 cursor-not-allowed' : ''}
                                `}
                            >
                                {registering ? (
                                    <span className="flex items-center justify-center">
                                        <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-current" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                        </svg>
                                        Processing...
                                    </span>
                                ) : (
                                    selectedEvent.resource?.isRegistered ? 'Unregister from Event' : 'Register for Event'
                                )}
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default CalendarPage;