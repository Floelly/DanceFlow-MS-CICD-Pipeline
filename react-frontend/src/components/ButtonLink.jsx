import PropTypes from 'prop-types';

import { Link } from "react-router-dom";

const ButtonLink = ({ text, toAction }) => {
  return (
    <Link className="btn btn-outline-primary mb-2" to={toAction}>
      {text}
    </Link>
  );
};

ButtonLink.propTypes = {
  text: PropTypes.string.isRequired,
  toAction: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.object
  ]).isRequired
}

export default ButtonLink;
