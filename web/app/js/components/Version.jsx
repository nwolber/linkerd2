import { apiErrorPropType } from './util/ApiHelpers.jsx';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import React from 'react';
import { withContext } from './util/AppContext.jsx';

class Version extends React.Component {
  static defaultProps = {
    error: null,
    latestVersion: '',
    productName: 'controller'
  }

  static propTypes = {
    error: apiErrorPropType,
    isLatest: PropTypes.bool.isRequired,
    latestVersion: PropTypes.string,
    productName: PropTypes.string,
    releaseVersion: PropTypes.string.isRequired,
  }

  numericVersion = version => {
    let parts = version.split("-", 2);
    if (parts.length === 2) {
      return parts[1];
    } else {
      return version;
    }
  }

  versionChannel = version => {
    let parts = version.split("-", 2);
    if (parts.length === 2) {
      return parts[0];
    }
  }

  renderVersionCheck = () => {
    const {latestVersion, error, isLatest} = this.props;

    if (!latestVersion) {
      return (
        <div>
          Version check failed{error ? `: ${error.statusText}` : ''}.
        </div>
      );
    }

    if (isLatest) {
      return "Linkerd is up to date.";
    }

    return (
      <div>
        A new version ({this.numericVersion(latestVersion)}) is available.<br />
        <Link
          to="https://versioncheck.linkerd.io/update"
          className="button primary"
          target="_blank">
          Update Now
        </Link>
      </div>
    );
  }

  render() {
    let channel = this.versionChannel(this.props.releaseVersion);
    let message = `Running ${this.props.productName || "controller"}`;
    message += ` ${this.numericVersion(this.props.releaseVersion)}`;
    if (channel) {
      message += ` (${channel})`;
    }
    message += ".";

    return (
      <div className="version">
        {message}<br />
        {this.renderVersionCheck()}
      </div>
    );
  }
}

export default withContext(Version);
