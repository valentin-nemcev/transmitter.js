import JointConnectionMessage from './JointConnectionMessage';


export default class NodePointTransmissionHub {

  constructor(comm, nodePoint) {
    this.comm = comm;
    this.transmission = this.comm.transmission;
    this.pass = this.comm.pass;
    this.nodePoint = nodePoint;
    this.updatedConnections = new Set();
  }

  sendForAll() {
    for (const connection of this.nodePoint.getConnectionsFor(this.comm)) {
      if (this._tryQueryConnection(connection)) {
        this.sendForConnection(connection);
      }
    }
    return this;
  }

  sendForConnection(connection) {
    if (!this.updatedConnections.has(connection)) {
      this.updatedConnections.add(connection);
      this.nodePoint
        .receiveCommunicationForConnection(this.comm, connection);
    }
    return this;
  }

  areAllConnectionsUpdated() {
    for (const connection of this.nodePoint.getConnectionsFor(this.comm)) {
      const msg = JointConnectionMessage.getOrCreate(this, {connection});
      if (!msg.isUpdated()) return false;
    }
    return true;
  }

  _tryQueryConnection(connection) {
    const msg = JointConnectionMessage.getOrCreate(this, {connection});
    if (!msg.isUpdated()) {
      msg.queryForNestedCommunication(this.comm);
      return false;
    } else {
      return true;
    }
  }
}
