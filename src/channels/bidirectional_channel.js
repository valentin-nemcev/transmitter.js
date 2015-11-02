import {inspect} from 'util';

import getNullChannel from './null_channel';
import SimpleChannel from './simple_channel';
import CompositeChannel from './composite_channel';

export default class BidirectionalChannel extends CompositeChannel {

  inspect() {
    const components = [this.origin, this.getDirection(), this.derived];
    return '(' + components.map(inspect).join('') + ')';
  }

  constructor() {
    // TODO: Refactor
    super();
    this.channels = null;
  }

  inForwardDirection() {
    this.channels = {
      forward: new SimpleChannel().inForwardDirection(),
      backward: getNullChannel(),
    };
    return this;
  }

  inBackwardDirection() {
    this.channels = {
      forward: getNullChannel(),
      backward: new SimpleChannel().inBackwardDirection(),
    };
    return this;
  }

  inBothDirections() {
    this.channels = {
      forward: new SimpleChannel().inForwardDirection(),
      backward: new SimpleChannel().inBackwardDirection(),
    };
    return this;
  }

  withOriginDerived(origin, derived) {
    this._getChannels().forward.fromSource(origin).toTarget(derived);
    this._getChannels().backward.fromSource(derived).toTarget(origin);
    return this;
  }

  withMapOrigin(mapOrigin) {
    this._getChannels().forward.withTransform(
      this._createTransform(mapOrigin, this.getMatchOriginDerived())
    );
    return this;
  }

  withMapDerived(mapDerived) {
    this._getChannels().backward.withTransform(
      this._createTransform(mapDerived, this.getMatchDerivedOrigin())
    );
    return this;
  }

  withMatchDerivedOrigin(matchDerivedOrigin) {
    this.matchDerivedOrigin = matchDerivedOrigin;
    return this;
  }

  withMatchOriginDerived(matchOriginDerived) {
    this.matchOriginDerived = matchOriginDerived;
    return this;
  }

  getMatchOriginDerived() {
    if (this.matchOriginDerived == null) {
      if (this.matchDerivedOrigin != null) {
        this.matchOriginDerived = (origin, derived) =>
          this.matchDerivedOrigin(derived, origin);
      }
    }
    return this.matchOriginDerived;
  }

  getMatchDerivedOrigin() {
    if (this.matchDerivedOrigin == null) {
      if (this.matchOriginDerived != null) {
        this.matchDerivedOrigin = (derived, origin) =>
          this.matchOriginDerived(origin, derived);
      }
    }
    return this.matchDerivedOrigin;
  }


  _createTransform(map, match) {
    if (match != null) {
      return (payload, tr) =>
        payload.updateMatching( (...args) => map(...args, tr), match);
    } else {
      return (payload, tr) =>
        payload.map( (...args) => map(...args, tr));
    }
  }

  _getChannels() {
    if (this.channels == null) {
      throw new Error('Direction was not specified');
    }
    return this.channels;
  }

  getChannels() {
    return [this._getChannels().backward, this._getChannels().forward];
  }
}
