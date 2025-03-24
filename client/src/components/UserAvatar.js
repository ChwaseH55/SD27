import React from 'react';

const UserAvatar = ({ user, size = 'md' }) => {
  const sizeClasses = {
    sm: 'w-8 h-8 text-xs',
    md: 'w-12 h-12 text-sm',
    lg: 'w-24 h-24 text-xl'
  };

  const getInitials = (user) => {
    if (!user) return '?';
    const firstname = user.firstname || '';
    const lastname = user.lastname || '';
    return `${firstname.charAt(0)}${lastname.charAt(0)}`.toUpperCase();
  };

  return (
    <div className={`relative ${sizeClasses[size]} rounded-full overflow-hidden bg-gray-200 flex items-center justify-center`}>
      {user?.profilePicture ? (
        <img
          src={user.profilePicture}
          alt={`${user.firstname} ${user.lastname}`}
          className="w-full h-full object-cover"
          onError={(e) => {
            e.target.style.display = 'none';
            e.target.nextSibling.style.display = 'flex';
          }}
        />
      ) : (
        <div className="w-full h-full flex items-center justify-center bg-yellow-500 text-white font-semibold">
          {getInitials(user)}
        </div>
      )}
    </div>
  );
};

export default UserAvatar; 