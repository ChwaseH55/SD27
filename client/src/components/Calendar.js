import React from 'react';
import { Calendar, dateFnsLocalizer } from 'react-big-calendar';
import 'react-big-calendar/lib/css/react-big-calendar.css';
import { format, parse, startOfWeek, getDay } from 'date-fns';
import enUS from 'date-fns/locale/en-US';
import Nav from './Nav'; // Import the Nav component

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

const events = [
    {
        title: 'Club Tournament',
        allDay: true,
        start: new Date(2025, 1, 14),
        end: new Date(2025, 1, 14),
    },
    {
        title: 'Practice Session',
        start: new Date(2025, 1, 16, 10, 0),
        end: new Date(2025, 1, 16, 12, 0),
    },
];

const CalendarPage = () => {
    return (
        <div className="flex flex-col min-h-screen bg-gray-100">
            {/* Navbar */}
            <Nav isLoggedIn={true} />

            {/* Header Section */}
            <header className="pt-20 pb-10 text-center bg-ucfBlack text-white">
                <h1 className="text-4xl font-bold">Calendar</h1>
                <p className="text-lg">Stay updated with upcoming events and activities.</p>
            </header>

            {/* Calendar Section */}
            <div className="flex flex-col items-center justify-center mx-auto p-6 bg-white shadow-lg rounded-lg mt-6 max-w-5xl">
                <Calendar
                    localizer={localizer}
                    events={events}
                    startAccessor="start"
                    endAccessor="end"
                    style={{ height: 500, width: '100%' }}
                />
            </div>
        </div>
    );
};

export default CalendarPage;