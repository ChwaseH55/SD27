import React, { useState, useEffect } from 'react';
import { Calendar, dateFnsLocalizer } from 'react-big-calendar';
import 'react-big-calendar/lib/css/react-big-calendar.css';
import { format, parse, startOfWeek, getDay } from 'date-fns';
import enUS from 'date-fns/locale/en-US';
import Nav from './Nav'; // Import the Nav component
import { api } from '../config'; // Update the import path for the api instance
import { useSelector } from 'react-redux';

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
    const [userEvents, setUserEvents] = useState([]);
    const user = useSelector(state => state.user.user);

    useEffect(() => {
        const fetchUserEvents = async () => {
            if (!user || !user.id) return;
            
            try {
                // Use the correct endpoint for fetching user's registered events
                const response = await api.get(`/events/my-events/${user.id}`);
                
                // Format events for the Calendar component
                const formattedEvents = response.data.map(event => ({
                    title: event.eventname,
                    start: new Date(event.eventdate),
                    end: new Date(new Date(event.eventdate).getTime() + 2 * 60 * 60 * 1000), // Add 2 hours as default duration
                    allDay: false,
                    resource: {
                        id: event.eventid,
                        location: event.eventlocation,
                        description: event.eventdescription
                    }
                }));
                
                setUserEvents(formattedEvents);
            } catch (error) {
                console.error("Error fetching user events:", error);
            }
        };

        fetchUserEvents();
    }, [user]);

    // Custom event component to show more details
    const EventComponent = ({ event }) => (
        <div>
            <strong>{event.title}</strong>
            {event.resource && event.resource.location && (
                <div><small>{event.resource.location}</small></div>
            )}
        </div>
    );

    return (
        <div className="flex flex-col min-h-screen bg-gray-100">
            {/* Navbar */}
            <Nav isLoggedIn={!!user} />

            {/* Header Section */}
            <header className="pt-20 pb-10 text-center bg-ucfBlack text-white">
                <h1 className="text-4xl font-bold">Calendar</h1>
                <p className="text-lg">Stay updated with upcoming events and activities.</p>
            </header>

            {/* Calendar Section */}
            <div className="flex flex-col items-center justify-center mx-auto p-6 bg-white shadow-lg rounded-lg mt-6 max-w-5xl">
                <Calendar
                    localizer={localizer}
                    events={userEvents}
                    startAccessor="start"
                    endAccessor="end"
                    style={{ height: 500, width: '100%' }}
                    components={{
                        event: EventComponent
                    }}
                />
            </div>
        </div>
    );
};

export default CalendarPage;