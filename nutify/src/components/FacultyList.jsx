import React from 'react';
import jaysonGuia from '../assets/images/avatars/d447a9fd5010652f6c0911fbe9c662c6.jpg';
import jeiPastranaAvatar from '../assets/images/avatars/1c9a4dd0bbd964e3eecbd40caf3b7e37.jpg';
import ireneBalmes from '../assets/images/avatars/c33237da3438494d1abc67166196484e.jpg';
import carloTorres from '../assets/images/avatars/8940e8ea369def14e82f05a5fee994b9.jpg';
import archieMenisis from '../assets/images/avatars/78529e2ec8eb4a2eb2fb961e04915b0a.jpg';
import michaelAramil from '../assets/images/avatars/869f67a992bb6ca4cb657fb9fc634893.jpg';
import erwinDeCastro from '../assets/images/avatars/92770c61168481c94e1ba43df7615fd8.jpg';
import joelEnriquez from '../assets/images/avatars/944c5ba154e0489274504f38d01bcfaf.jpg';
import bernieFabito from '../assets/images/avatars/78529e2ec8eb4a2eb2fb961e04915b0a.jpg';
import bobbyBuendia from '../assets/images/avatars/237d3876ef98d5364ed1326813f4ed5b.jpg';
import pennyLumbera from '../assets/images/avatars/237d3876ef98d5364ed1326813f4ed5b.jpg';

const facultyList = [
  { id: 1, name: 'Jayson Guia', department: 'Faculty - SACE', status: 'online', avatar: jaysonGuia },
  { id: 2, name: 'Jei Pastrana', department: 'Faculty - SACE', status: 'offline', avatar: jeiPastranaAvatar },
  { id: 3, name: 'Irene Balmes', department: 'Faculty - SACE', status: 'online', avatar: ireneBalmes },
  { id: 4, name: 'Carlo Torres', department: 'Faculty - SACE', status: 'offline', avatar: carloTorres },
  { id: 5, name: 'Archie Menisis', department: 'Faculty - SACE', status: 'online', avatar: archieMenisis },
  { id: 6, name: 'Michael Joseph Aramil', department: 'Faculty - SACE', status: 'offline', avatar: michaelAramil },
  { id: 7, name: 'Erwin De Castro', department: 'Faculty - SACE', status: 'online', avatar: erwinDeCastro },
  { id: 8, name: 'Joel Enriquez', department: 'Faculty - SACE', status: 'offline', avatar: joelEnriquez },
  { id: 9, name: 'Bernie Fabito', department: 'Faculty - SACE', status: 'online', avatar: bernieFabito },
  { id: 10, name: 'Bobby Buendia', department: 'Faculty - SAHS', status: 'online', avatar: bobbyBuendia },
  { id: 11, name: 'Penny Lumbera', department: 'Faculty - SAHS', status: 'offline', avatar: pennyLumbera }
];

const FacultyList = ({ mainSearch, facultyStatusFilter, setFacultyStatusFilter }) => {
  const filteredFacultyList = facultyList.filter(f =>
    (facultyStatusFilter === 'all' || f.status === facultyStatusFilter) &&
    (f.name.toLowerCase().includes(mainSearch.toLowerCase()) ||
      f.department.toLowerCase().includes(mainSearch.toLowerCase()))
  );

  return (
    <div className="moderator-home-faculty-section">
      <div className="moderator-home-section-header" style={{ justifyContent: 'space-between', alignItems: 'center' }}>
        <h2 style={{ margin: 0 }}>All Faculty List</h2>
        <select
          id="faculty-status-filter"
          value={facultyStatusFilter}
          onChange={e => setFacultyStatusFilter(e.target.value)}
          className="moderator-home-faculty-filter-dropdown"
        >
          <option value="all">All</option>
          <option value="online">Online</option>
          <option value="offline">Offline</option>
        </select>
      </div>
      <div className="moderator-home-faculty-list">
        {filteredFacultyList.map(faculty => (
          <div
            key={faculty.id}
            className="moderator-home-faculty-item"
          >
            <div className="moderator-home-faculty-avatar">
              <img src={faculty.avatar} alt={faculty.name} className="moderator-home-avatar-img" />
            </div>
            <div className="moderator-home-faculty-info">
              <div className="moderator-home-faculty-name">{faculty.name}</div>
              <div className="moderator-home-faculty-department">{faculty.department}</div>
            </div>
            <div className={`moderator-home-faculty-status ${faculty.status}`}></div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default FacultyList;
