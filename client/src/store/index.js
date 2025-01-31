import { configureStore } from "@reduxjs/toolkit";
import userReducer from "../reducers/userReducer";

const loadState = () => {
    try {
        const serializedState = localStorage.getItem('reduxState');
        return serializedState ? JSON.parse(serializedState) : undefined;
    } catch (err) {
        console.error('Failed to load state', err);
        return undefined;
    }
};

const store = configureStore({
    reducer: {
        user: userReducer,
    },
    preloadedState: loadState(), // Hydrate on page load
});

store.subscribe(() => {
    try {
        const stateToPersist = store.getState();
        const serializedState = JSON.stringify(stateToPersist);
        localStorage.setItem('reduxState', serializedState);
    } catch (err) {
        console.error('Faled to save state', err);
    }
})

export default store;