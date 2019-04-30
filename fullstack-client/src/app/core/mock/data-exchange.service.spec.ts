import { TestBed } from '@angular/core/testing';

import { DataExchangeService } from './data-exchange.service';

describe('DataExchangeService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: DataExchangeService = TestBed.get(DataExchangeService);
    expect(service).toBeTruthy();
  });
});
