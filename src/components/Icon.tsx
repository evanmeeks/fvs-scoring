import React from "react";

interface IconProps {
  name: string;
  className?: string;
}

const Icon: React.FC<IconProps> = ({ name, className = "" }) => (
  <span className={`material-symbols-outlined select-none ${className}`}>
    {name}
  </span>
);

export default Icon;
