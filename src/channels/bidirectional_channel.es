import {inspect} from 'util';

import * as directions from '../directions';

import getNullChannel from './null_channel';
import SimpleChannel from './simple_channel';
import CompositeChannel from './composite_channel';

function id(a) { return a; }

export default class BidirectionalChannel extends CompositeChannel {

  inspect() {
    const components = [this.origin, this.getDirection(), this.derived];
    return '(' + components.map(inspect).join('') + ')';
  }

  inForwardDirection() { return this.inDirection(directions.forward); }
  inBackwardDirection() { return this.inDirection(directions.backward); }

  inDirection(direction) {
    this.direction = direction;
    return this;
  }

  getDirection() {
    return this.direction != null ? this.direction : directions.omni;
  }

  withOrigin(origin) {
    this.origin = origin;
    return this;
  }

  withDerived(derived) {
    this.derived = derived;
    return this;
  }

  withTransformOrigin(transformOrigin) {
    this.transformOrigin = transformOrigin;
    return this;
  }

  withTransformDerived(transformDerived) {
    this.transformDerived = transformDerived;
    return this;
  }

  withMapOrigin(mapOrigin) {
    this.mapOrigin = mapOrigin;
    return this;
  }

  withMapDerived(mapDerived) {
    this.mapDerived = mapDerived;
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


  createTransform(map, match) {
    if (match != null) {
      return (payload, tr) =>
        payload.updateMatching( (...args) => map(...args, tr), match);
    } else {
      return (payload, tr) =>
        payload.map( (...args) => map(...args, tr));
    }
  }

  getTransformOrigin() {
    return this.transformOrigin || this.createTransform(
      this.mapOrigin || id, this.getMatchOriginDerived());
  }

  getTransformDerived() {
    return this.transformDerived || this.createTransform(
      this.mapDerived || id, this.getMatchDerivedOrigin());
  }

  createSimple(source, target, transform, direction) {
    return new SimpleChannel()
      .inDirection(direction)
      .fromSource(source)
      .toTarget(target)
      .withTransform(transform);
  }

  getForwardChannel() {
    if (this.getDirection().matches(directions.forward)) {
      return new SimpleChannel()
        .inForwardDirection()
        .fromSource(this.origin)
        .toTarget(this.derived)
        .withTransform(this.getTransformOrigin());
    } else {
      return getNullChannel();
    }
  }

  getBackwardChannel() {
    if (this.getDirection().matches(directions.backward)) {
      return new SimpleChannel()
        .inBackwardDirection()
        .fromSource(this.derived)
        .toTarget(this.origin)
        .withTransform(this.getTransformDerived());
    } else {
      return getNullChannel();
    }
  }

  getChannels() {
    if (this.channels.length === 0) {
      this.channels = [
        this.getForwardChannel(),
        this.getBackwardChannel(),
      ];
    }
    return this.channels;
  }
}
