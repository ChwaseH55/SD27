import React, { Fragment } from "react";
import {Link} from 'react-router-dom';
import {isAuth} from '../utils/functions';
import { useHistory } from "react-router-dom";

const Nav = () => {
const history = useHistory();

const logout = () => {
  localStorage.removeItem('auth');
  history.push('/login')
}

    return (
        <ul className="nav border">
  <li className="nav-item">
    <Link className="nav-link" aria-current="page" to="/">Home</Link>
  </li>

{isAuth() ? (
  <Fragment>
  <li className="nav-item">
    <span onClick={logout} className="nav-link">Logout</span>
  </li>
  </Fragment>
) : (
  <Fragment>
  <li className="nav-item">
    <Link className="nav-link" to="/register">Sign up</Link>
  </li>
  <li className="nav-item">
    <Link className="nav-link" to="/login">Login</Link>
  </li>
  </Fragment>
)}
</ul>
    );
};

export default Nav;