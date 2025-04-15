import React from 'react';

const UserAvatar = ({ user, size = 'md' }) => {
  const sizeClasses = {
    sm: 'w-8 h-8 text-xs',
    md: 'w-12 h-12 text-sm',
    lg: 'w-24 h-24 text-xl'
  };

  const getInitials = (user) => {
    if (!user) return '?';
    // Handle both camelCase and lowercase property names
    const firstname = user.firstname || user.firstName || '';
    const lastname = user.lastname || user.lastName || '';
    return `${firstname.charAt(0)}${lastname.charAt(0)}`.toUpperCase();
  };

  const handleImageError = (e) => {
    e.target.style.display = 'none';
    const fallback = e.target.nextSibling;
    if (fallback) {
      fallback.style.display = 'flex';
    }
  };

  // Handle both camelCase and lowercase property names
  const profilePicture = user?.profilePicture || user?.profilepicture;
  const firstName = user?.firstname || user?.firstName || '';
  const lastName = user?.lastname || user?.lastName || '';

  return (
    <div className={`relative ${sizeClasses[size]} rounded-full overflow-hidden bg-gray-200 flex items-center justify-center`}>
      {profilePicture ? (
        <>
          <img
            src={profilePicture}
            alt={`${firstName} ${lastName}`}
            className="w-full h-full object-cover"
            onError={handleImageError}
          />
          <div className="w-full h-full hidden items-center justify-center bg-yellow-500 text-white font-semibold">
            {getInitials(user)}
          </div>
        </>
      ) : (
        <div className="w-full h-full flex items-center justify-center bg-yellow-500 text-white font-semibold">
          {getInitials(user)}
        </div>
      )}
    </div>
  );
};

export default UserAvatar; 